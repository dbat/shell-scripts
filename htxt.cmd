@echo OFF
setlocal enableExtensions enableDelayedExpansion
goto START

:Help
echo.
echo. Convert *.htm to *.txt
echo.
echo. Requires: HTMLasText (nirsoft's freeware utility)
echo.
echo. Usage: %~n0 [sourcedir] [destdir]
echo.   sourcedir: source dir of html files
echo.   destdir: destination dir to put the text files
echo.
echo.   - both arguments are optional default to current dir
echo.   - sourcedir must be a valid dir, whereas
echo.     destdir will be created if not yet exist
echo.
echo. Copyright PT SOFTINDO, Jakarta 2017
echo. 2017.01.02
echo.
exit /b


:realpath var_iden path
rem %1 MUST be a VALID variable identifier - no checking
::echo ON
set "arg=%~1"
if not defined arg exit /b
set "arg=%~2"
if not defined arg (set "%1=%CD%") else set "%1=%~dpnx2"
exit /b


:START
set "arg=%~1"
set "arg=%arg:~0,1%"
if "%arg%"=="/" goto Help

call :realpath SRCDIR "%~1"
call :realpath DSTDIR "%~2"


if not exist "%SRCDIR%\" (echo. ERROR: Invalid sourcedir: "%SRCDIR%") & goto Help
if not exist "%SRCDIR%"\*.htm (echo. ERROR: No html files found in %SRCDIR%) & goto Help

echo source files = %SRCDIR%/*.htm
echo dest files = %DSTDIR%/*.txt

if not exist "%DSTDIR%\" mkdir "%DSTDIR%"

set "H2TCFG=%TEMP%\%~n0_%random%_tmp.cfg"
::echo config-temp %H2TCFG%
>"%H2TCFG%" echo [Config]
>>"%H2TCFG%" echo ConvertMode=2
>>"%H2TCFG%" echo TableCellDelimit=3
>>"%H2TCFG%" echo CharsPerLine=32000
>>"%H2TCFG%" echo Source=%SRCDIR%\*.htm
>>"%H2TCFG%" echo Dest=%DSTDIR%\*.txt

::echo SRCFILES = %SRCDIR%\*.htm
::echo DSTFILES = %DSTDIR%\*.txt
::type "%H2TCFG%"

htmlastext /run "%H2TCFG%"
sed -i "/^.$/d" "%DSTDIR%"\*.txt

if exist "%H2TCFG%" del /q "%H2TCFG%"






