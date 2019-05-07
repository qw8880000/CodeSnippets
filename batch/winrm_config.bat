@echo off
setlocal EnableDelayedExpansion
:start
cls
::--------------------------------------------------------
::-- 全局变量
::--------------------------------------------------------
set item=
set Protocal_Choice=
set Protocal=
set HostName=
set Port=
set UserName=
set Password=
set Choice=
set Hosts=
set GroupName=
set GroupSid=

echo.查看或设置WinRM......
echo.------------------------------------------
echo.0-查看WinRM版本信息    6-启用WinRM-Http
echo.1-查看WinRM配置信息    7-创建Https数字证书
echo.2-查看WinRM侦听状态    8-查看Https数字证书
echo.3-测试WinRM连接状态    9-启用WinRM-Https
echo.4-查看默认共享         a-启用non-administrator
echo.5-禁用WinRM            x-退出
echo.------------------------------------------
set /p item=请选择:
echo.------------------------------------------

::0-查看WinRM版本信息
if /i "%item%"=="0" (call winrm id)

::1-查看WinRM配置信息
if /i "%item%"=="1" (call winrm get winrm/config)

::2-查看WinRM侦听状态
if /i "%item%"=="2" (call winrm e winrm/config/listener)

::3-测试WinRM连接状态
if /i "%item%"=="3" (
  :input_protocal
  set /p Protocal_Choice="请输入连接协议(1-http,2-https):"
  if not "!Protocal_Choice!"=="1" (if not "!Protocal_Choice!"=="2" goto:input_protocal)
  set /p HostName="请输入连接主机:"
  set /p Port="请输入连接端口:"
  set /p UserName="请输入用户名:"
  set /p Password="请输入口令:"
  echo.------------------------------------------
  if /i "!Protocal_Choice!"=="1" (set Protocal=http) else (if /i "!Protocal_Choice!"=="2" (set Protocal=https))
  echo.测试命令为：winrm identify -r:!Protocal!://!HostName!:!Port! -auth:basic -u:!UserName! -p:!Password! -encoding:utf-8
  set /p Choice="确认请输入Y/y,任意键退出:"
  echo.------------------------------------------
  if /i "!Choice!"=="y" (call winrm identify -r:!Protocal!://!HostName!:!Port! -auth:basic -u:!UserName! -p:!Password! -encoding:utf-8)
)

::4-查看默认共享
if /i "%item%"=="4" (
  net share
)

::5-禁用WinRM
if /i "%item%"=="5" (
  call winrm delete winrm/config/Listener?Address=*+Transport=HTTP
  call winrm delete winrm/config/Listener?Address=*+Transport=HTTPS
)

::6-启用WinRM-Http
if /i "%item%"=="6" (
  :input_port_6
  set /p Port="请输入连接端口:"
  if "!Port!"=="" (goto:input_port_6)
  :input_hosts_6
  set /p Hosts="请输入允许连接的远程主机:（* or host1,host2... or 192.168.1.*）"
  if "!Hosts!"=="" (goto:input_hosts_6)
  call winrm quickconfig -quiet
  call winrm set winrm/config @{MaxTimeoutms ="600000000"}
  call winrm set winrm/config/service/auth @{Basic="true"}
  call winrm set winrm/config/client/auth @{Basic="true"}
  call winrm set winrm/config/service @{AllowUnencrypted="true"}
  call winrm set winrm/config/client @{AllowUnencrypted="true"}
  call winrm set winrm/config/winrs @{MaxMemoryPerShellMB="1024"}
  call winrm set winrm/config/client/DefaultPorts @{HTTP="!Port!"}
  call winrm set winrm/config/client @{TrustedHosts="!Hosts!"}
  call winrm delete winrm/config/Listener?Address=*+Transport=HTTP
  call winrm create winrm/config/listener?Address=*+Transport=HTTP @{Port="!Port!"}
)

::7-创建Https数字证书
if /i "%item%"=="7" (
  :input_hostname_7
  set /p HostName="请输入IP地址:"
  if "!HostName!"=="" (goto:input_hostname_7)
  call selfssl.exe /T /N:cn=!HostName! /V:36500 /Q
  call powershell "Get-childItem cert:\LocalMachine\Root\ | Select-String -pattern !HostName!"
)

::8-查看Https数字证书
if /i "%item%"=="8" (
  set /p HostName="请输入IP地址:"
  call powershell "Get-childItem cert:\LocalMachine\Root\ | Select-String -pattern !HostName!"
)

::9-启用WinRM-Https
if /i "%item%"=="9" (
  :input_hostname_9
  set /p HostName="请输入IP地址:"
  if "!HostName!"=="" (goto:input_hostname_9)
  :input_port_9
  set /p Port="请输入连接端口:"
  if "!Port!"=="" (goto:input_port_9)
  :input_hosts_9
  set /p Hosts="请输入允许连接的远程主机:（* or host1,host2... or 192.168.1.*）"
  if "!Hosts!"=="" (goto:input_hosts_9)
  :input_Thumbprint_9
  set /p Thumbprint="请输入证书Thumbprint:"
  if "!Thumbprint!"=="" (goto:input_Thumbprint_9)
  call winrm quickconfig -quiet
  call winrm set winrm/config @{MaxTimeoutms ="600000000"}
  call winrm set winrm/config/service/auth @{Basic="true"}
  call winrm set winrm/config/client/auth @{Basic="true"}
  call winrm set winrm/config/winrs @{MaxMemoryPerShellMB="1024"}
  call winrm set winrm/config/client/DefaultPorts @{HTTPS="!Port!"}
  call winrm set winrm/config/client @{TrustedHosts="!Hosts!"}
  call winrm delete winrm/config/Listener?Address=*+Transport=HTTPS
  call winrm create winrm/config/listener?Address=*+Transport=HTTPS @{Port="!Port!"; Hostname="!HostName!"; CertificateThumbprint="!Thumbprint!"}
  
)

::a-启用non-administrator
if /i "%item%"=="a" (
  echo.前提:手工创建用户账号
  echo.本步骤实现:1.将用户加入到administrators组，2.设置默认共享注册表测策略，3.设置powershell执行策略
  echo.注意:1.确认默认共享已开（C$、D$...）
  echo.     2.防火墙允许TCP445/139端口和WinRM端口连接
  echo.--------------------------------------------------------------
  :input_username_a
  set /p UserName="请输入用户账号名称:"
  if "!UserName!"=="" (goto:input_username_a)
  call net localgroup administrators !UserName! /add
  call REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 1 /f
  call powershell -command set-ExecutionPolicy RemoteSigned
)

if /i "%item%"=="x" (goto:eof) else (echo.&pause&goto:start)

::b-启用non-administrators
if /i "%item%"=="b" (
  echo.前提:手工创建WinRM用户组，将普通用户加入到该组内
  echo.1.显示WinRM用户组的sid，2.允许组用户连接WinRM
  echo.注意:1.只能执行脚本命令，无法传输文件
  echo.     2.防火墙允许WinRM端口连接
  echo.-------------------------------------------------
  :input_groupname_b
  set /p GroupName="请输入WinRM用户组名称:"
  if "!GroupName!"=="" (goto:input_groupname_b)
  call wmic group get name, sid|findstr "!GroupName!"
  :input_groupsid_b
  set /p GroupSid="请输入WinRM用户组Sid:"
  if "!GroupSid!"=="" (goto:input_groupsid_b)
  call winrm set winrm/config/service @{RootSDDL="O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;!GroupSid!)S:P(AU;FA;GA;;;WD)(AU;SA;GWGX;;;WD)"}
)



