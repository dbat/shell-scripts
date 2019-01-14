@echo OFF
setLocal enableExtensions enableDelayedExpansion
::rem SET THIS TO CUSTOMIZE TARGET
set "SOURCELIST=0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15... a 1a"
set "SOURCES0=*.?asm *.as? *.a *.inc *.mac *.lst *.cod *.c *.h *.mak Makefile dis-*"
set "SOURCES0="
set "SOURCES1=*.?asm *.as? *.a *.mac *.inc Makefile"
set "SOURCES2=*.c *.h *.def *.rc *.mak Makefile"
set "SOURCES3=*.pas *.dfm *.res *.dpr *.dof *inc"
set "SOURCES4=*.bat *.cmd *.ps *.js *.ws *.vbs"
set "SOURCES5=*.exe *.dll *.sys *.bin *.com"
set "SOURCES6=*.txt *.not *.inf *.cfg *.asc"
set "SOURCESa=*.obj *.lst *.cod"
set "SOURCES1a=%SOURCES1% %SOURCESa%"
set "SOURCES=%SOURCES0%"
set "this=%~dpnx0"
set "name=%~n0"
goto START

:Help
echo.
echo. Batch script to backup sources
echo. Version: 2009.01.07
echo.
echo. Synopsys:
echo.     Check whether if source-set has changed. If there's
echo.     any file changed or new file added, then ALL files
echo.     in the source-set will be backed up.
echo.
echo.     Useful for maintaining working state of project, to
echo.     avoid mixing-up good and forgotten bad/buggy files.
echo.
echo. Usage:
echo.     %name% [ -go ] [ -SOURCE_INDEX... ] [ more-wildcards... ]
echo.
echo.     Where SOURCE_INDEX is one of:
echo.
for %%i in (%SOURCELIST%) do if defined SOURCES%%~i ^
echo.         -%%i : !SOURCES%%~i!
echo.
echo.     more-wildcards:
echo.         Additional files to be included in source-set
echo.
echo.     Arguments will be accumulated to curent source-set
echo.
echo.   NOTE: Without "-go" switch, display only, no real execution
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
  call %cmb% %cmbop% "%~nx1" "%backupdir%\%pre%\%~nx1"
  if not errorlevel 0 echo. "%%~nxf different" & set /a "updated=%updated%+1"
exit /b

:START

for %%a in ("" - /) do if /i "%~1"=="%%~a?" goto Help
for %%a in (- /) do if /i "%~1"=="%%~ah" goto Help

set "echo=@echo"
set "echoswitch=off"
set "gtrnul=^>nul"
if /i "%~1"=="-go" shift & set "echo=" & set "echoswitch=off" & set "gtrnul=>nul"

:LoopSRC
set "arg=%~1"
if not defined arg goto source_done
if "%~1"=="/?" ( goto Help ) else if "%~1"=="/h" goto Help
for %%i in (%SOURCELIST%) do if "%arg%"=="-%%i" ( shift & set "SOURCES=!SOURCES! !SOURCES%%i!" & goto LoopSRC)

:LoopADD
set "arg=%~1"
if "%~1"=="/?" ( goto Help ) else if "%~1"=="/h" goto Help
if not defined arg goto source_done
set "SOURCES=%SOURCES% %~1"
shift
goto Loopadd

:source_done
if "%SOURCES%"=="" goto Help
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
set "cmbop="
set "updated=0"
for %%f in (cmb.exe) do set "cmb=%%~$PATH:f"
if defined cmb goto chkUpdate
if not defined cmb goto update
set "cmb=fc.exe" revert to windows - not reliable
set "cmbop=/lb1"
goto chkUpdate

:chkUpdate
::rem for %%f in (*.pas *.dfm *.dpr) do ()
::for %%f in (%~dpnx0 %SOURCES%) do (
::for %%f in ("%this%" %SOURCES%) do (
::@echo ON
@for %%f in (%SOURCES%) do if exist "%%~f" (
  %cmb% %cmbop% "%%~f" "%backupdir%\%pre%\%%~nxf"
  @REM echo err:%errorlevel%
  if not errorlevel 0 echo. %%~nxf changed & set /a "updated=!updated!+1"
)
@echo OFF
rem echo updated=%updated%
if "%updated%" gtr "0" (
  echo. %updated% file^(s^) has been changed.
  if not defined echo (
    echo.&echo.ALL files in SOURCE-SET will be backed-up to "%backupdir%\%got%\"
	<nul set/p=Press [CTRL-C] to abort. &pause
  )
  goto update
)

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
if defined echo echo.This is mode: TEST/SHOW ONLY. Pass argument: "-go" to apply changes.
if defined echo echo.
if defined echo pause
