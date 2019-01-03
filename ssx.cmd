@echo off
setLocal enableExtensions enableDelayedExpansion
goto START
:Help
@echo.
@echo.  Local extract msi setup
@echo.
@echo.  Arguments:
@echo.	%~n0 [ switch ^| files.. ]
@echo.
@echo.	files	Extract the specified files
@echo.
@echo.	switch	Extract all files in:
@echo.	  .	current dir
@echo.
@echo.	  -s	.\subdir
@echo.
@echo.	  -ss	.\subdir and .\subdir\sub-subdir
goto EOF

:START
set A1=%~1
if not defined A1 goto Help


set x=.x
set DESTDIR=%cd%\%x%
set LOGDIR=%DESTDIR%\.ERRORS
if not exist "%LOGDIR%" md "%LOGDIR%"

set exec=msiexec /quiet /qn /le "%LOGDIR%\%%~nf.LOG" /a "%%~f" /qb TARGETDIR="%DESTDIR%"
rem echo %exec%

rem goto done
rem exit /b

if "%~1"=="." goto curdir
if "%~1"=="-s" goto subdirs
if "%~1"=="-ss" goto subdir2

goto single


:curdir
for %%f in (*.msi) do echo.installing %%~f&start /wait %exec%
goto done

echo on

:subdirs
for /d %%d in (*) do if not "%%~d"=="%x%" for %%f in (%%d\*.msi) do (echo.installing %%~f&start /wait %exec%)
goto done

:subdir2
for /d %%d in (*) do if not "%%~d"=="%x%" (
	for %%f in (%%d\*.msi) do echo.installing %%~f&start /wait %exec%
	for /d %%e in (%%d\*) do for %%f in (%%e\*.msi) do (echo.installing %%~f&start /wait %exec%)
)
goto done


:single
for %%f in (%*) do start %exec%
goto eof

:done
pause


:EOF
