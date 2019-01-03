@echo OFF
goto START

:Help
@echo OFF
echo.
echo. SYNOPSYS:
echo.   Set environment variable with vacant countered log filename
echo.
echo.   For example, if log-000..log199 already exist, this script
echo.   will set the given environment variable to: log-200
echo.
echo. USAGE:
echo.     %~n0 ENVAR [ basename ]
echo.
echo.     ENVAR     (required) environment variable to be set
echo.     basename  basename for log filename (default:"log")
echo.
echo. NOTES:
echo.   Counter range is [000..999]
echo.
exit /b

:getLogname ENVAR_FOR_LOGNAME BASENAME_FOR_LOGFILE
setLocal enableDelayedExpansion
::to be customized by user, set how many digits
::not-available-yet:: set "MAXN=3"

set "LOGENVAR=%~1"
if not defined LOGENVAR set "LOGENVAR=LOGFILE"

set "basename=%~2"
if not defined basename set "basename=log"

set "num="
for /l %%r in (0,1,9) do @if not exist "%basename%-00%%r" set "num=00%%r" & goto ndone1
:ndone1
::echo num=%num%

if defined num goto num_done
for /l %%r in (10,1,99) do @if not exist "%basename%-0%%r" set "num=0%%r" & goto ndone2
:ndone2
::echo num=%num%

if defined num goto num_done
for /l %%r in (100,1,999) do @if not exist "%basename%-%%r" set "num=%%r" & goto ndone3
:ndone3
::echo num=%num%

:num_done

if not defined num set "num=ERR"

echo %LOGENVAR%=%basename%-%num%
endlocal & set "%LOGENVAR%=%basename%-%num%"

exit /b

:START
setLocal
  set A1=%~1
  if not defined A1 goto Help
  if ^%A1:~0,1%==^" goto Help
endLocal

call :getLogname %~1

