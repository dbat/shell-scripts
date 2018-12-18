@echo off
setLocal enableExtensions enableDelayedExpansion
set "this=%~n0"
if "%~1"=="" goto Help

set "LOG=_LOG-%RANDOM%"
set "DEBUG=@rem" & set "NOTES=@rem"
goto START

:Help
@echo OFF & @echo.
::
:: Copyright 2003-2011 Adrian H., Ray AF and Raisa NF
:: Private property of PT SOFTINDO Jakarta
::
:: https://github.com/dbat/scripts
@echo. Create links of files/dirs in the specified dir DESTDIR
@echo.
@echo. Usage: %this% destdir [ -h ] [ -j ] [ -r ] filename...
@echo.
@echo.   destdir (required): Directory where symlinks to be created 
@echo.
@echo.   -h (optional) : make hardlink for file links
@echo.
@echo.   -j (optional) : make juntion point for directory links
@echo.                   (default is using /d switch)
@echo.
@echo.   -r (optional) : create relatif path if possible
@echo.
@echo.   filename: Full path filename or directory to be referenced
@echo.
@echo. Example parameters for Total-Commander's custom button-bar:
@echo. (Right-click empty part of button bar, select "Change..")
@echo.
@echo.   ? -r "%%T" %%P%%S : %%T must be quoted while %%P%%S must not
@echo.
@echo.   tooltip: Make symlinks of selections in the other panels

::@rem file: %commander_path%\default.bar
::@rem [ButtonBar]
::@rem button39=WINCMD32.EXE,38
::@rem cmd39=mklinx.cmd
::@rem param39=-r "%T" %P%S

::@rem pause only if not in console
@for %%v in (%cmdcmdline%) do set blah=%%~v
if /i not %blah%==%comSpec% @echo.&@pause
goto:EOF

:clearerr
exit /b 0

:set (internal SET clone to avoid scanning for file named SET.EXECUTABLE)
:: CALL SET always return 0, see http://ss64.com/nt/call.html
set %*& exit /b 0

:isDir STRING
setLocal enableDelayedExpansion
set "arg=%~1"
if not defined arg exit /b -1
@rem if defined %1 set "arg=!%~1!"
for /d %%d in ("%arg%") do set "attr=%%~ad"
if defined attr if "%attr:~0,1%"=="d" exit /b 0
exit /b 1

:isHelp
setLocal
for %%a in ("" - /) do if /i "%~1"=="%%~a?" exit /b 0
for %%a in (h help -h -help) do if /i "%~1"=="-%%a" ( exit /b 0 ) else if /i "%~1"=="/%%a" ( exit /b 0 ) 
exit /b 1

:mkRelPath file base -- makes a file name relative to a base path
::                   -- file [in,out] - variable with file name to be converted,
::                      or file name itself for result in stdout
::                   -- base [in,opt] - base path, leave blank for current directory
:$created 20060101 :$changed 20110219 :$categories Path
:$source https://www.dostips.com
:$changes call :set based on info from https://ss64.com/nt/call.html
setLocal enableDelayedExpansion
set "src=%~1"
if not defined src exit /b 1
if defined %1 set "src=!%~1!"
set "base=%~2"
if not defined base set "base=%CD%"
::for %%s in (%src%) do set "src=%%~dpnxd"
::for %%b in (%base%) do set "base=%%~dpnxd"
for /f "tokens=*" %%f in ("%src%") do set "src=%%~ff"
for /f "tokens=*" %%d in ("%base%") do set "base=%%~fd"
set "match=" variable to store matching part of the name
set "upDir=" variable to reference a parent
for /f "tokens=*" %%a in ('@echo.%base:\=^&@echo.%') do (
  @rem %DEBUG%: echo src=%src%, sub="!sub!" a="%%a", match="!match!" upDir="!upDir!"
  set "sub=!sub!%%a\"
  call :set "tmp=%%src:!sub!=%%"
  @rem %NOTES%: this can't handle path with unpaired double-quotes...
  if /i "!tmp!" neq "!src!" ( set "match=!sub!" ) else set "upDir=!upDir!..\"
)
set "src=%upDir%!src:%match%=!"
endLocal & if defined %1 ( set "%~1=%src%" ) else @echo.%src%
exit /b 0


:START
::echo on
call :isHelp "%~1" && goto Help

set "flag1H=" & set "flag1J=" & set "flag1R=" 

:HoopLa
set "arg="
for %%a in (H J R) do if /i "%~1"=="-%%a" set "arg=1" & set "flag1%%a=1"
if defined arg shift & goto HoopLa

if defined flag1J ( set "OPDIR=/j" ) else set "OPDIR=/d"
if defined flag1H ( set "OPFILE=/h" ) else set "OPFILE="

call :isDir "%~1" && ( set "dest=%~dpnx1" & shift ) || ( @echo.@echo.ERROR: Invalid dir: "%~1" & exit /b )
::echo on

:Loop1
if "%~1"=="" goto Lope1end
call :isHelp "%~1" && goto Help
call :isDir "%~1" && set "isDIR=1" || set "isDIR="
if defined isDIR ( set "op=%OPDIR%" ) else set "op=%OPFILE%"

set "getReal="
if defined flag1R if /i "%~d1"=="%dest:~0,2%" (
  if defined isDIR (
    if not defined flag1J set "getReal=1"
  ) else if not defined flag1H set "getReal=1"
)

@rem %DEBUG%: echo isDIR="%isDIR%" op="%op%" OPDIR="%OPDIR%" OPFILE="%OPFILE%" getReal="%getReal%"

set "target=%~1"
if defined getReal call :mkRelPath target "%dest%"

if "%dest:~-1%"=="\" if "%dest:~3%" neq "" set "dest=%dest:~0,-1%" validate, chop last backslash except for rootdir
mklink %op% "%dest%\%~nx1" "%target%"
shift & goto Loop1
:Lope1end

:DONE
::pause
