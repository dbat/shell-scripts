@echo OFF
setlocal enableExtensions enableDelayedExpansion
set "this_script=%~sf0"

::CUSTOMIZE_THIS!!
set "destdrive=u:"
set "dirmode=1"
set "testmode=1"
set "GOON="

if "%~1"=="" goto Help
if "%~1"=="-go" set "GOON=-go" & set "testmode=" & shift
if defined testmode ( set "echo=@echo" ) else set "echo="

set "digs=%~f1"
if not defined digs set "digs=%CD%"
set "digs=%digs%\"
set "digd=%digs:~2%"
set "toucher=toucher"

goto START
:Help
@echo.
@echo. SYNOPSYS:
@echo. 	Synchronize datetime folder with the same name
@echo. 	in the specified drive, recursively
@echo.
@echo. 	(sync DEST_DRIVE\SOURCE_DIR with SOURCE_DIR)
@echo.
@echo. USAGE:
@echo. 	%~n0 source_dir (TEST only)
@rem @echo. 		(TESTMODE is in effect)
@echo. 	%~n0 -go [ source_dir ]
@rem @echo. 		(force disable TESTMODE)
@echo.
@echo. 	if not specified, source_dir = current dir
@echo.
@echo. REQUIRES:
@echo. 	toucher (www.github.com/dbat/toucher)
@echo.
@echo. NOTES:
@echo. 	Please customize ENVARS below^!
@echo.	
@echo. 	DESTDRIVE : Destination drive = "%destdrive%"
@echo. 	DIRMODE   : Directory only = "%dirmode%"
@rem @echo. 	TESTMODE  : Test only = "%testmode%"
@rem @echo. 	(TESTMODE always OFF if -go argument is given)
@echo.	
pause
goto EOF

:START
set "attr=%~a1"
set "islink="
if defined attr set "islink=%attr:~8,1%"
if /i [%islink%]==[l] goto EOF

if defined dirmode goto START_1

:START_0
for /f "delims=\" %%f in ('dir /b "%digs%"*') do (
  %echo% toucher -l -r "%digs%%%~f" "%destdrive%%digd%%%~f"
)

:: d-------l
:: 012345678

:START_1
for /f "delims=\" %%d in ('dir /b /ad "%digs%"*') do (
  %echo% toucher -l -r "%digs%%%~d" "%destdrive%%digd%%%~d"
  set "attr=%%~ad"
  set "islink=!attr:~8,1!"
  rem @echo add=%%~ad %%~d, attr=!attr!, islink=!islink!
  if /i not [!islink!]==[l] call %this_script% %GOON% "%digs%%%~d"
)

if defined testmode echo.TESTMODE on. No modification applied.
:EOF
