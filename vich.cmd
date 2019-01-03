@echo OFF
if "%~1"=="" goto EOF
setLocal enableExtensions enableDelayedExpansion
set "EDITOR=vi"
set "tobeedit="
@for /f "usebackq" %%f in (`where "%~1"`) do @if exist "%%f" set "tobeedit=!tobeedit! "%%f""
if defined tobeedit %EDITOR% %tobeedit%
:EOF
