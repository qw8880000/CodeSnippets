@echo off
:main
ver | find "5.1." > NUL && call :win_xp
ver | find "6.1." > NUL && call :win7
goto end

:win7
for /f "tokens=2 delims=:" %%i in ('ipconfig^|findstr "IPv4"') do (
  set ip=%%i
)
exit /b 0

:win_xp
for /f "tokens=2 delims=:" %%i in ('ipconfig^|findstr "IP Address"') do (
  set ip=%%i
)
exit /b 0

:end
echo ip=%ip%
pause
