@echo OFF
::echo ON
if "%~1"=="" goto HELP
setLocal enableExtensions enableDelayedExpansion
goto BEGIN

:HELP
@echo OFF
echo.
echo. Calculate the time difference.
echo. Returns seconds elapsed (including excess +1 second).
echo.
echo. Copyright 2017, Adrian H, Ray AF and Raisa NF
echo. Version: 1.0.1
echo. Created: 2017.07.20
echo. Revised: 2017.07.27
echo.
echo. Usage:
echo.	%~n0  [time_start] [time_end]
echo.
echo. Time format and separator:
echo.	format:  ss, mm:ss, hh:mm:ss or DD:hh:mm:ss
echo.	         - No 23/59's restriction, any value is allowed.
echo.	         - Max value is about 595000 days
echo.	         - Positive integer only, negative and decimal sign
echo.		   are considered as token separator. see below:
echo.	separator:  [/:.-] (slash, colon, dot, hyphen)
echo.
echo. Example:
echo.	%~n0  0 0  (will return 1 second)
echo.	%~n0  123/234/345  6:7.8-9  (returns 99865 seconds)
echo.
echo. Limitation:
echo.	Batch work with integer, granularity is limited to second
echo.
echo.	Beware that %%TIME%% value is including 1/100-th second
echo.	this will be interpreted by this script as DD:hh:mm:ss
echo.	you should chop the last 3 chars with: %%TIME:~0,3%%
echo.
exit /b

:funParseDateTime
setLocal
For /f "tokens=2-4 delims=/ " %%a in ("%DATE%") do (
    set YYYY=%%c
    set MM=%%a
    set DD=%%b
)
For /f "tokens=1-4 delims=/:." %%a in ("%TIME%") do (
    set HH24=%%a
    set MI=%%b
    set SS=%%c
    set FF=%%d
)
echo %%DATE%%=%DATE%
echo %%TIME%%=%TIME%
echo %YYYY%-%MM%-%DD%_%HH24%-%MI%-%SS%-%FF%
echo %YYYY%/%MM%/%DD% %HH24%:%MI%:%SS%
echo %MM%/%DD%/%YYYY% %HH24%:%MI%:%SS%
echo YYYY=%YYYY%
echo MM=%MM%
echo DD=%DD%
echo HH24=%HH24%
echo MI=%MI%
echo SS=%SS%
echo FF=%FF%

endLocal
exit /b


:seteval ARG NUM
set "%~1=" & set "sn=%~2"
if not defined sn exit /b
:Loop0trim
if "%sn%"=="0" set /a "%~1=0" & exit /b
if "%sn:~0,1%"=="0" set "sn=%sn:~1%" & goto Loop0trim
set /a "%~1=%sn%"
exit /b


:funTimeToSec var time
if [%2]==[] set "%1=0" & exit /b

For /f "tokens=1-4 delims=/:-." %%a in ("%2") do (
  set "a=%%~a" & set "b=%%~b" & set "c=%%~c" & set "d=%%~d"
)

call :seteval a %a%
call :seteval b %b%
call :seteval c %c%
call :seteval d %d%

if defined d (
    set /a "%1=(%a%+0) * 86400 + (%b%+0) * 3600 + (%c%+0) * 60 + (%d%+0)"
) else (
    if defined c (
        set /a "%1=(%a%+0) * 3600 + (%b%+0) * 60 + (%c%+0)"
     ) else (
         if defined b (
             set /a "%1=(%a%+0) * 60 + (%b%+0)"
         ) else set /a "%1=%a% + 0"
     )
 )

exit /b

:funSectoTime VAR seconds
set /a "secs=%~2 + 0"
set "neg=-"
if %secs% LSS 0 ( set /a "secs=-%secs%" ) else set "neg="

set /a "ss=%secs% %% 60"
set /a "mm=%secs% %% 3600"
set /a "mm=%mm% / 60"
set /a "hh=%secs% / 3600"

if %ss% LSS 10 set "ss=0%ss%"
if %mm% LSS 10 set "mm=0%mm%"
if %hh% LSS 10 set "hh=0%hh%"

set "%~1=%neg%%hh%:%mm%:%ss%"
exit /b


:funGetElapsedTime
::@echo OFF
call :funTimeToSec tm1 %1
call :funTimeToSec tm2 %2
set /a elapse=%tm2% - %tm1% +1

call :funSectoTime STIME %elapse%

echo start:%tm1% stop:%tm2% elapsed=%elapse% (%STIME%)

exit /b

:BEGIN

call :funGetElapsedTime %*

:DONE



