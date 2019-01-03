@echo OFF
setLocal enableExtensions
goto START

:Help
@echo.
@echo. Get datetime from NTP Server
@echo. Can be piped to DATE or TIME command to change date/time
@echo.
@echo. Requires: sed
@echo.
@echo. Usage: %~n0 [ -d ^| -t ]
@echo. 	
@echo. 	-d : parse date only
@echo. 	-t : parse time only
@echo. 	
@echo.	(default is get both date and time)
@echo.
@echo. Examples:
@echo. 	Set current date:
@echo. 	    %~n0 ^| @date
@echo. 	    
@echo. 	Set current time:
@echo. 	    %~n0 -t ^| @time
@echo.
goto EOF

:START
::w32tm /stripchart /computer:0.pool.ntp.org /dataonly /samples:0
::RESULT::
::	Tracking 0.pool.ntp.org [173.71.69.215:123].
::	Collecting 0 samples.
::	The current time is 17/11/2018 04:03:41 AM.

set "NTPS=0.pool.ntp.org"
set "OPTS=/stripchart /computer:%NTPS% /dataonly /samples:0"
set "NUMS=[0-9]\+"


if "%~1"=="/d" goto getDate
if "%~1"=="-d" goto getDate

if "%~1"=="/t" goto getTime
if "%~1"=="-t" goto getTime

if not "%~1"=="" goto Help

:getDateTime
w32tm %OPTS% | sed -n "/time is/s/[^0-9 \/:]//gp"
goto EOF

:getDate
w32tm %OPTS% | sed -n "/^.* \(%NUMS%\/%NUMS%\/%NUMS%\).*$/s//\1/p"
goto EOF

:getTime
w32tm %OPTS% | sed -n "/^.* \(%NUMS%:%NUMS%:%NUMS%\).*$/s//\1/p"
goto EOF

:EOF
