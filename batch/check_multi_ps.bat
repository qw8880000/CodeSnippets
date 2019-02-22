@echo off

::=======================================
:: 主程序
:: 功能：用来判断系统进程是否存在，可通过参数传入多个进程
:: 参数：以逗号分格，如ps1,ps2,ps3
::=======================================

:main
set params=%*
set process_found=
set process_no_found=
set process_no_found_count=0

setlocal enabledelayedexpansion
for %%a in (%params%) do (
  set p=%%a
  tasklist | findstr !p! > NUL
  if not !errorlevel! == 0 (
    set process_no_found=!process_no_found! "!p!"
    set /a process_no_found_count=!process_no_found_count! + 1
  ) else (
    set process_found=!process_found! "!p!"
  )
)
setlocal disabledelayedexpansion

if "%process_no_found_count%" == "0" (
  echo OK. all found [process: %process_found%].
) else (
  echo NO FOUND [count:%process_no_found_count%, process: %process_no_found%]
)

exit /b 0
