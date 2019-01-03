@echo off
setLocal enableExtensions enableDelayedExpansion
if not "%~1"=="-go" (
  echo. Syntax:
  echo. 	%~n0 -go [ directory ^| wildcards... ]
  echo.
  echo. 	Set datetime of ALL files under DIR to be identical with DIR
  echo.
  echo. Please type "-go" as the first argument to confirm &pause &exit /b
)
shift
set "TOUCH=toucher"
:Loop
  set "arg=%~1"
  if not defined arg goto DONE
  for /r %%d in (.) do %touch% -t "%~1" "%%d"
  shift
goto Loop

:DONE
