@echo OFF
setLocal enableExtensions enableDelayedExpansion
::rem SET THIS TO CUSTOMIZE TARGET
set "SOURCELIST=0 1 2 3"
set "SOURCES0=*.?asm *.as? *.a *.inc *.lst *.mac *.c *.h dis-*"
set "SOURCES1=*.pas *.dfm *.res *.dpr *.dof *inc"
set "SOURCES2=*.bat *.cmd *.ps *.js *.ws *.vbs"
set "SOURCES3=*.exe *.dll *.sys *.bin *.com"
set "SOURCES=%SOURCES0%"
set "this=%~dpnx0"
set "name=%~n0"
goto START

:Help
echo.
echo. Batch script to backup sources
echo. Version: 2008.01.02
echo.
echo. Synopsys:
echo.   Check whether if source-set has changed. If there's
echo.   any file changed or new file added, then ALL files
echo.   in the source-set will be backed up.
echo.
echo.   Useful for maintaining working state of project, to
echo.   avoid mixing-up good and forgotten bad/buggy files.
echo.
echo. Usage:
echo. 	%name% [ -go ] [ source-id ]
echo.
echo.   Where source-id is: (DEFAULT = 0)
echo.
for %%i in (%SOURCELIST%) do ^
echo.     %%i : !SOURCES%%~i!
echo.
echo.    ... you can expand further by adding them in the script
echo.
echo.   NOTE: without -go argument, show only, no real execution
echo.
pause
exit /b

:error10000
echo. ===========================================
echo. Amazing!
echo. You have already used up all 10000 backups
echo.
echo. Good job.
echo. ===========================================
exit /b

:Loop10
@for /l %%i in (0,1,8) do (
  if exist "%backupdir%\00%%i\" (
    set /a "r=%%i+1" >nul
    set "pre=00%%i"
    set "got=00!r!"
  ) else  exit /b
)
if exist "%backupdir%\%got%\" set "pre=%got%" & set "got=010"
exit /b

:Loop100
@for /l %%i in (10,1,98) do (
  if exist "%backupdir%\0%%i\" (
    set /a "r=%%i+1" >nul
    set "pre=0%%i"
    set "got=0!r!"
  ) else exit /b
)
if exist "%backupdir%\%got%\" set "pre=%got%" & set "got=100"
exit /b

:Loop033
@for /l %%i in (33,1,98) do (
  if exist "%backupdir%\0%%i\" (
    set /a "r=%%i+1" >nul
    set "pre=0%%i"
    set "got=0!r!"
  ) else exit /b
)
if exist "%backupdir%\%got%\" set "pre=%got%" & set "got=100"
exit /b

:Loop1000
@for /l %%i in (100,1,998) do (
  if exist "%backupdir%\%%i\" (
    set /a "r=%%i+1" >nul
    set "pre=%%i"
    set "got=!r!"
  ) else exit /b
)
if exist "%backupdir%\%got%\" set "pre=%got%" & set "got=1000"
exit /b

:Loop10000
@for /l %%i in (1000,1,9998) do (
  if exist "%backupdir%\%%i\" (
    set /a "r=%%i+1" >nul
    set "pre=%%i"
    set "got=!r!"
  ) else exit /b
)
if exist "%backupdir%\%got%\" set "pre=%got%" & set "got=10000"
exit /b


:fileCompare filename
  call %cmb% "%~nx1" "%backupdir%\%pre%\%~nx1"
  if not errorlevel 0 echo. "%%~nxf different" & set /a "updated=%updated%+1"
exit /b

:START

for %%a in ("" - /) do if /i "%~1"=="%%~a?" goto Help
for %%a in (- /) do if /i "%~1"=="%%ah" goto Help

set "echo=@echo"
set "echoswitch=off"
set "gtrnul=^>nul"
if /i "%~1"=="-go" shift & set "echo=" & set "echoswitch=off" & set "gtrnul=>nul"
set "arg=%~1"
if not defined arg goto source_done
for %%i in (%SOURCELIST%) do if "%arg%"=="%%i" set "SOURCES=!SOURCES%%i!"
:source_done
echo. SOURCES = %SOURCES%

@echo %echoswitch%
@rem echo ON

set "backupdir=.backup"
set "pre="
set "got=000"

call :Loop10
if not exist "%backupdir%\%got%\" goto doneCheck
call :Loop100
if not exist "%backupdir%\%got%\" goto doneCheck
call :Loop1000
if not exist "%backupdir%\%got%\" goto doneCheck
call :Loop10000
if not exist "%backupdir%\%got%\" goto error10000

:doneCheck
@rem echo ON

set "cmb="
set "updated=0"
for %%f in (cmb.exe) do set "cmb=%%~$PATH:f"
if "%cmb%"=="" goto update

goto chkUpdate

:chkUpdate
::rem for %%f in (*.pas *.dfm *.dpr) do ()
::for %%f in (%~dpnx0 %SOURCES%) do (
::for %%f in ("%this%" %SOURCES%) do (
for %%f in (%SOURCES%) do (
  call %cmb% "%%~f" "%backupdir%\%pre%\%%~nxf"
  if not errorlevel 0 echo. %%~nxf changed & set /a "updated=!updated!+1"
)
rem echo updated=%updated%
if "%updated%" gtr "0" echo. %updated% file(s) has been changed. &pause& goto update

echo. Last backup directory: "%backupdir%\%pre%"
echo. No file has been changed. Backup is not needed.
goto update_done

:update
echo.
set "got=%backupdir%\%got%"
%echo% mkdir "%got%"
if not defined echo echo. Backup dir: %got%

::for %%f in (%~dpnx0 %SOURCES%) do (
::for %%f in ("%this%" %SOURCES%) do (
for %%f in (%SOURCES%) do (
  rem if not defined echo <nul set/p="%%f "
  if not defined echo echo. copying %%f
  %echo% copy /y "%%~f" "%got%" %gtrnul%
)
:update_done
if defined echo echo.
if defined echo echo.This is a test/show mode only
if defined echo echo.Pass argument -go to do real execution
if defined echo echo.
pause
