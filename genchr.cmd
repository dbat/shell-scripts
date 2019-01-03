@echo off
setLocal
set "USAGE=echo:Usage: %~n0 [0-255]& goto :EOF"
if "%~1" equ "" %USAGE%
set /a "val=%~1" 2>nul
if "%~1" neq "%val%" %USAGE%
if %~1 lss 0 %USAGE%
if %~1 gtr 255 %USAGE%

set tempfile=%~1.tmp
set "options=/d compress=off /d reserveperdatablocksize=26"

set "echo="
if "%~2"=="-v" set "echo=echo:"

if %~1 equ 26 (
	copy /y nul + nul /a 26.chr /a >nul
) else (
	type nul >"%tempfile%"
	makecab %options% /d reserveperfoldersize=%~1 "%tempfile%" %~1.chr >nul
	type %~1.chr | (
		(for /l %%N in (1 1 38) do pause)>nul&findstr "^">"%tempfile%")
	>nul copy /y "%tempfile%" /a %~1.chr /b
	%echo%del "%tempfile%"
)

%echo%rem %~1.chr