@echo OFF
if not "%OS%"=="Windows_NT" goto PlainDOS
setLocal enableExtensions enableDelayedExpansion
set "A1=%~1"
if not defined A1 goto HELP
for %%a in ("" - /) do if "%A1%"=="%%~a?" goto HELP
goto OLD_WindowsNT

:Help
@echo. Find executables (.exe .dll .sys etc.) in path by wildcards 
@echo. Example: which disk* fs*
goto DONE

:OLD_WindowsNT
:Loop1
set "A1=%~1"
if not defined A1 goto DONE

for %%e in (.sys .dll .ocx .msc .cpl %PATHEXT%) do (
  if exist "%1%%e" for %%f in ("%1%%e") do echo %%~zf	%%~nxf ^(current dir^)
)

::replace destructive parentheses 
set "BLAH=%PATH:(=[\\%"
set "BLAH=%BLAH:)=//]%"

if not "%~1"=="" (
  for %%d in (%BLAH: =`'%) do (
    for %%e in (.sys .dll .ocx %PATHEXT%) do (
      set "FPATH=%%~d"
      set "FPATH=!FPATH:`'= !"
      set "FPATH=!FPATH:[\\=^(!"
      set "FPATH=!FPATH://]=^)!"
      if exist "!FPATH!\%~n1%%e" for %%f in ("!FPATH!\%~n1%%e") do echo %%~zf	%%~dpnxf
    )
  )
)
shift

goto Loop1
goto DONE

:WindowsNT
:LOOP
if "%~1"=="" goto DONE
for %%e in (.sys .dll .ocx .bin %PATHEXT%) do (
  for %%f in (%~n1%%e) do if not "%%~$PATH:f"=="" echo %%~$PATH:f
)
shift
goto LOOP


:PlainDOS
@if _%1_==__ goto HELP
@for %%d in (. %PATH%) do @if exist "%%d\%1" echo %%d\%1
@for %%d in (. %PATH%) do @if exist "%%d\%1.bat" echo %%d\%1.bat
@for %%d in (. %PATH%) do @if exist "%%d\%1.cmd" echo %%d\%1.cmd
@for %%d in (. %PATH%) do @if exist "%%d\%1.com" echo %%d\%1.com
@for %%d in (. %PATH%) do @if exist "%%d\%1.exe" echo %%d\%1.exe
@for %%d in (. %PATH%) do @if exist "%%d\%1.msc" echo %%d\%1.msc
@for %%d in (. %PATH%) do @if exist "%%d\%1.sys" echo %%d\%1.sys
@for %%d in (. %PATH%) do @if exist "%%d\%1.dll" echo %%d\%1.dll
@for %%d in (. %PATH%) do @if exist "%%d\%1.ocx" echo %%d\%1.ocx
@for %%d in (. %PATH%) do @if exist "%%d\%1.vbs" echo %%d\%1.vbs
@for %%d in (. %PATH%) do @if exist "%%d\%1.cs"  echo %%d\%1.cs
@for %%d in (. %PATH%) do @if exist "%%d\%1.js"  echo %%d\%1.js
@for %%d in (. %PATH%) do @if exist "%%d\%1.wsc" echo %%d\%1.wsc
@for %%d in (. %PATH%) do @if exist "%%d\%1.wsh" echo %%d\%1.wsh
goto DONE

:DONE
