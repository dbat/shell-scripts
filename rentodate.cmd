@echo OFF
setLocal enableExtensions enableDelayedExpansion
set "echo=@echo"
if /i "%~1"=="-go" set "echo="
if /i "%~1"=="-go" shift
goto START

:Help
@echo.
@echo. Rename file, appended with it's datetime
@echo. CAUTION: using dd/mm/yyyy format (EUROPE/AU/ASIA)
@echo.
@echo. Usage: %~n0 -go WILDCARD
@echo.
goto EOF

:START
set "ARG=%1"
if not defined ARG goto Help

for %%f in (%ARG%) do (
  set "stamp=%%~tf"
  set dd=!stamp:~0,2!
  set mm=!stamp:~3,2!
  set yy=!stamp:~8,2!
  set mi=!stamp:~11,2!
  set ss=!stamp:~14,2!
  %echo% ren "%%f" "%%~nf-!yy!!mm!!dd!_!mi!!ss!%%~xf"
)


:EOF
