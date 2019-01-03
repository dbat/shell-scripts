@echo OFF
if "%OS%"=="Windows_NT" goto WindowsNT
goto DOS


:WindowsNT
setLocal
start %~dp0wincmd\wincmd32.exe "%cd%"
goto :eof


:DOS
if exist x:\bin\nul set cbin=x:\bin
if exist b:\bin\nul set cbin=b:\bin
if exist c:\bin\nul set cbin=c:\bin
if "%CBIN%"=="" set CBIN=C:\BIN
if %NC%.==. set NC=%CBIN%\NC55
rem below REQUIRES DOS 7.1 from Windows 98+
%NC%\NC
goto EOF

:EOF
