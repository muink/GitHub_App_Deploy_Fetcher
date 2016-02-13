:: GitHub App Deploy Fetcher
:: Extraction latest GitHub Desktop installation resources
:: Author: muink

@echo off&title GitHub App Deploy Fetcher
mode con: cols=80 lines=28

:[init]
set download_url=https://github-windows.s3.amazonaws.com
set appfile_path=GitHub.application
set appfiles_path=%~dp0Application Files
set manifest_tag=codebase=.*\.manifest
set manifest_path=Application Files\GitHub_X_X_X_X\GitHub.exe.manifest
set curl_path=bin\curl


:[main]
::download appfile
rem call:[url_coding] "%appfile_path:\=/%" "current_url"
rem call:[path_name_cut] "%appfile_path%" "cfilepath" "cfilename"
rem %curl_path% %current_url% -o%cfilename%
rem call:[filetree_sort] "%cfilepath%" "%cfilename%"
%curl_path% -O %download_url%/%appfile_path%


::fetch manifest path
call:[fetch_path] "%manifest_tag%" "%appfile_path%" "manifest_path"


::download manifest file
call:[url_coding] "%manifest_path:\=/%" "current_url"
call:[path_name_cut] "%manifest_path%" "cfilepath" "cfilename"
%curl_path% %current_url% -o%cfilename%
call:[filetree_sort] "%cfilepath%" "%cfilename%"


:[end]
pause
goto :eof





:[fetch_path]
setlocal enabledelayedexpansion
for /f "delims=" %%p in ('findstr -i "%~1" "%~2"') do set temp_path="%%~p"
set temp_path=!temp_path:^&=#26!
set temp_path=!temp_path:^^=#5E!
set temp_path=!temp_path:^<=[!
set temp_path=!temp_path:^>=]!
for /f "tokens=2 delims=@" %%p in (%temp_path:codebase=@%) do set temp_path=%%p
for /f "tokens=1 delims=@" %%p in ("%temp_path:size=@%") do set temp_path=%%p
for /f "tokens=1 delims==" %%p in ("%temp_path:~0,-1%") do set temp_path=%%~p
for %%i in ("%temp_path%") do endlocal&set %~3=%%~i
goto :eof


:[url_coding]
setlocal enabledelayedexpansion
set temp_url="%download_url%/%~1"
set temp_url=%temp_url: =@20%
set temp_url=%temp_url:`=@60%
set temp_url=%temp_url:{=@7B%
set temp_url=%temp_url:}=@7D%
set temp_url=!temp_url:@=%%!
for %%i in (%temp_url%) do endlocal&set %~2=%%~i
goto :eof


:[path_name_cut]
setlocal enabledelayedexpansion
for /f "delims=" %%i in ("%manifest_path%") do endlocal&set %~2=%%~dpi&set %~3=%%~nxi
goto :eof


:[filetree_sort]
setlocal enabledelayedexpansion
md "%~1">nul 2>nul
move /y "%~2" "%~1">nul
goto :eof
