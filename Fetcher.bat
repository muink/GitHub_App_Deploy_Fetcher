:: GitHub App Deploy Fetcher
:: Extraction latest GitHub Desktop installation resources
:: Author: muink

@echo off&title GitHub App Deploy Fetcher
color 3b
mode con: cols=80 lines=14

:[init]
set download_url=https://github-windows.s3.amazonaws.com
set appfile_path=GitHub.application
set manifest_tag=codebase=.*\.manifest
set manifest_path=Application Files\GitHub_X_X_X_X\GitHub.exe.manifest
set otherfiles_tag=size=
set curl_path=bin\curl
set idm_path=
::bin check
%curl_path% -h>nul 2>nul||echo.Bin file is corrupted, please download again...&&ping -n 3 127.0.0.1>nul&&goto [end]
if not defined idm_path set idm_path=idman
start "" "%idm_path%">nul 2>nul&&set choose_2=[2]Add to IDM queue(Quick)


:[main]
::download appfile
%curl_path% -O %download_url%/%appfile_path%||del /f/q %appfile_path%>nul 2>nul&&echo.Download failed, please check your network...&&ping -n 3 127.0.0.1>nul&&goto [end]
::fetch manifest info
call:[path_extract] "%manifest_tag%" "%appfile_path%" "manifest_path"
call:[url_coding] "%manifest_path:\=/%" "c_url"
call:[path_name_cut] "%manifest_path%" "cfilepath" "cfilename" 1
::download manifest file
%curl_path% %download_url%/%c_url% -o%cfilename%||del /f/q %cfilename%>nul 2>nul&&echo.Download failed, please check your network...&&ping -n 3 127.0.0.1>nul&&goto [end]
call:[filetree_sort] "%cfilepath%" "%cfilename%" 1
::init2
call:[url_coding] "%cfilepath:\=/%" "zone_url"
set "download_url=%download_url%/%zone_url%"
set "zone_path=%cfilepath%"
:: that is allright!!


:[main]choose
setlocal enabledelayedexpansion
cls
echo.&echo.Primary work is over, please choose the mode you want run&echo.
echo.    [1]Make a list file(Default)    %choose_2%&echo.
set ny=1&set /p ny=     Please choose: 
if "!ny!" == "1" (call:[run_mode] 1)>list.txt&echo.&echo.   List generation is completed...&ping -n 3 127.0.0.1>nul&goto [end]
if not "%choose_2%" == "" if "!ny!" == "2" (
   call:[run_mode] 2
   echo.&echo.   Queue addition is complete...&echo.
   set ny=y&set /p ny=Start idm queue and exits this program?[Y/N]
   if "!ny!" == "y" "%idm_path%" /s&echo.&echo.   Queue has started...&echo.&ping -n 3 127.0.0.1>nul
   start "" "%idm_path%"
   goto [end]
)
endlocal
goto [main]choose


:[end]
echo.&echo.Press any key to exit...&pause>nul
goto :eof



:[path_extract]
setlocal enabledelayedexpansion
for /f "delims=" %%p in ('findstr -i "%~1" "%~2"') do set "coding_path=%%p"
call:[path_coding] "coding_path"
for /f "delims=" %%i in ("%coding_path%") do endlocal&set "%~3=%%i"
goto :eof


:[path_coding]
setlocal enabledelayedexpansion
set "temp_path=!%~1!"
rem set "temp_path=!temp_path:&=#26!"
rem set "temp_path=!temp_path:^=#5E!"
for /f "tokens=2 delims=@" %%p in ("%temp_path:codebase=@%") do set "temp_path=%%p"
for /f "tokens=2 delims=@" %%p in ("%temp_path:file name=@%") do set "temp_path=%%p"
for /f "tokens=1 delims=@" %%p in ("%temp_path:size=@%") do set "temp_path=%%p"
for /f "tokens=1 delims==" %%p in ("%temp_path:~0,-1%") do set "temp_path=%%~p"
for /f "delims=" %%i in ("%temp_path%") do endlocal&set "%~1=%%i"
goto :eof


:[url_coding]
setlocal enabledelayedexpansion
set temp_url=%~1
set temp_url=%temp_url: =@20%
set temp_url=%temp_url:`=@60%
set temp_url=%temp_url:{=@7B%
set temp_url=%temp_url:}=@7D%
set temp_url=!temp_url:@=%%!
for /f "delims=" %%i in ("%temp_url%") do endlocal&set "%~2=%%i"
goto :eof


:[path_name_cut]
setlocal enabledelayedexpansion
for /f "delims=" %%i in ("%~1") do (
   set "temp_path=%%i"
   if %4 == 1 set "temp_path=!temp_path:\%%~nxi=!"
   if %4 == 0 set "temp_path=!temp_path:%%~nxi=!"
   for /f "delims=" %%j in ('echo."!temp_path!"') do (
      endlocal&set "%~2=%%~j"&set "%~3=%%~nxi"
   )
)
goto :eof


:[filetree_sort]
setlocal enabledelayedexpansion
md "%~1">nul 2>nul
if "%3" == "1" move /y "%~2" "%~1">nul
goto :eof


:[run_mode]
setlocal enabledelayedexpansion
::fetch other files path
for /f "delims=" %%p in ('findstr -i "%otherfiles_tag%" "%manifest_path%"') do (
   set "coding_path=%%p"
   call:[path_coding] "coding_path"
   set "otherfiles_path=!coding_path!"
   call:[url_coding] "!otherfiles_path:\=/!" "c_url"
   call:[path_name_cut] "!otherfiles_path!" "cfilepath" "cfilename" 0
   call:[filetree_sort] "%zone_path%\!cfilepath!" "!cfilename!"
   if %1 == 1 (
      echo.url:	%download_url%/!c_url!.deploy
      echo.out:	%~dp0%zone_path%\!cfilepath!
      echo.
   )
   if %1 == 2 (
      set "download_path=%~dp0%zone_path%\!cfilepath!"
      "%idm_path%" /d %download_url%/!c_url!.deploy /p "!download_path:~0,-1!" /a
   )
)
endlocal
goto :eof
