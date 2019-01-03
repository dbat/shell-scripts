@echo OFF
if "%~1"=="-v" shift & echo on
:Loop
if "%~1"=="" pause & exit /b
echo processing %~1..
if not exist "%~1" goto shift
md ".x\%~1"
msiexec /a "%~n1" /qb TARGETDIR="%cd%\.x\%~n1"
:shift
shift
goto Loop