@echo OFF
setLocal enableExtensions enableDelayedExpansion
goto START

:blow
:HELP
echo. %*
echo. Copyright 2003-2012, PT SOFTINDO, Jakarta
echo. All rights reserved.
echo.
echo. Show environtments' length, with their first and last char
echo.
echo. Usage:
echo. 	%~n0 [ args... ]
echo.	Show some specified environment variables
echo.
echo. 	%~n0 -all
echo. 	Enumerates ALL environment variables
echo.
echo. Notes:
echo. 	Environment variables with length 1 will show the
echo. 	same values for both their first and last char
echo. 	(it doesn't mean to have the length more than 1)
echo.
exit /b

:enumset
rem set "all="
for /f "delims==" %%s in ('set') do call %0 %%s
exit /b


:START
::echo ON
if "%~1"=="" goto HELP
if /i "%~1"=="-?" goto HELP
if /i "%~1"=="--?" goto HELP
if /i "%~1"=="-h" goto HELP
if /i "%~1"=="--h" goto HELP
if /i "%~1"=="-help" goto HELP
if /i "%~1"=="--help" goto HELP
if /i "%~1"=="/?" goto HELP
if /i "%~1"=="/h" goto HELP
if /i "%~1"=="/help" goto HELP
if /i "%~1"=="-all" goto enumset
if /i "%~1"=="/all" goto enumset

:Loop
call set "arg101=%~1"
if not defined arg101 goto done
call set "arg101=%%%arg101%%%"

if not defined arg101 echo.%~1 = (empty) & goto next

set /a "r=0" > nul
set "alpha=%arg101:~0,1%"
set "chr=%alpha%"
:loop2
    set "omega=%chr%"
    set "chr=!arg101:~%r%,1!"
    set /a "r+=1"
    if "%arg101%"=="%alpha%" goto skipLoop1
if not "^%chr%"=="^" goto loop2
:skipLoop1
echo.%~1 (length = %r%), value = '%alpha%' .. '%omega%'

:next
shift
goto Loop

:done