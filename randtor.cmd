@echo OFF
setLocal enableExtensions enableDelayedExpansion

rem change this according to your Tor browser location:
set "TOR_DIR=p:\Browsers\toR"
set "MIN=49152"
set "MAX=65530"
set "MIN=1025"
set "MAX=49152"
set "LAST=0"

goto START

:showHelp
echo.
echo. Usage: %~n0 -go
echo. ::
echo. :: Some websites blocked tor (which usually using port out 443)
echo. ::
echo. :: This script will randomize tor's port by changing field in:
echo. :: [INSTALLDIR]\Browser\TorBrowser\Data\Tor\torrc-defaults
rem echo. ::   ExitNodes {US}
echo. ::   ExtORPort %RANDOM% (example)
echo. ::
echo. :: On Mac, the config is:
echo. :: ~/Library/Application Support/TorBrowser-Data/torrc
echo. ::
echo. Copyright 2003-2017, PT SOFTINDO, Jakarta
echo.
echo. Customizable environment, current settings:
echo.   TOR_DIR="%TOR_DIR%"
echo.   Random port MIN=%MIN%, MAX=%MAX% (inclussive)
echo.   Current port out: %LAST%
goto:eof


:START
rem set "echo="
rem if not "%~1"=="-go" set echo=echo

set "LAST=0"
set "config=%TOR_DIR%\Browser\TorBrowser\Data\Tor\torrc-defaults"
findstr /b /i ExtORPort "%config%" > nul || echo.No Port has been defined
if not errorlevel 1 (
  for /f "tokens=1,2" %%a in ('findstr /b /i ExtORPort "%config%"') do set /a "LAST=%%b+0"
  if /i "%~1"=="-go" (
    copy /y "%config%" "%config%".bak > nul
    findstr /v /b /i ExtORPort "%config%".bak > "%config%"
  )
)

if not "%~1"=="-go" goto showHelp

echo.Last port used: %LAST%
echo.Getting random port between %MIN% and %MAX%
:Loop
set /a PORT=%RANDOM% * %RANDOM% / %RANDOM%
if %PORT% lss %MIN% echo.%PORT% is not accepted & goto Loop
if %PORT% gtr %MAX% echo.%PORT% is not accepted & goto Loop
if %PORT% equ %LAST% echo.%PORT% is not accepted & goto Loop
echo.%PORT% - OK

echo.ExtORPort %PORT%>> "%config%"
echo.Done. You have to restart tor browser for change to take effect