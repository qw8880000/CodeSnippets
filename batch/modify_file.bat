@echo off

set FILE=test.conf
set TEMPFILE=test.conf.modify

::
:: 按行处理文件，包括空行
::
setlocal enabledelayedexpansion
for /f "tokens=1,* delims=:" %%a in ('findstr /n .* "%FILE%"') do (
  set line=%%b
  if "!line!" == "" (
    :: 输出一个换行
    echo.>>"%TEMPFILE%"
  ) else (
    :: 取line的前7位字符
    if "!line:~0,7!"=="LogFile" (
      echo LogFile=c:/dir>>"%TEMPFILE%"
    ) else (
      echo !line!>>"%TEMPFILE%"
    )
  )
)
setlocal disabledelayedexpansion

pause
