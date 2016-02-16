GitHub App Deploy Fetcher
=========================
提取最新的GitHub桌面程序安装资源[Win]  
解决由于网络环境问题导致的下载中断/出错问题

### 如何使用

 - 双击即食
   - 开始执行程序会下载`GitHub.application`部署文件在本程序当前目录下
   - 并在程序当前目录下创建`Application Files\GitHub_X_X_X_X`目录用于储存安装资源
 - 第二阶段
   1. 在程序当前目录下创建`list.txt`文件,其包含了下载链接和对应保存位置,使用下载工具下载即可
      - 由于本程序并不提供稳定快速的下载工具,您需要自行选择下载工具进行下载
   2. 直接调用idm进行下载,程序调用idm并将下载链接与保存位置添加到idm队列
      - 队列添加完毕后您可自行选择立即执行idm队列或您稍后手动执行队列
      - 想使用此功能需在环境变量`path`中正确添加idm的安装路径
      - 或在程序[第19行](./Fetcher.bat#L19)等号后正确添加idman.exe的完整路径
 - 完成阶段
   - 当完成下载并将资源文件按正确名字和位置放置好后
   - 执行`GitHub.application`部署文件
   - 如果没有问题,部署文件会自动完成GitHub的安装

### 报错?

 - Bin file is corrupted, please download again...
   - 请重新下载`bin`目录下的程序文件
 - Download failed, please check your network...
   - 未连接到网络和各种原因导致的下载中断
   - 由于本程序并不提供断点续传的功能,需重新执行程序再次下载


### License
GNU General Public License/GNU GPL v2
