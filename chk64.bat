@echo OFF
goto STARTCHK

:STARTCHK
@if not "%OS%"=="Windows_NT" goto DOS
@setLocal enableExtensions
@if not exist "%windir%\syswow64\cmd.exe" goto Win32
@goto Win64

:Win64
@rem echo.Windows 64-bit
set "ARC=64"
if "%ProgramW6432%"=="%ProgramFiles%" (
	@rem echo.64-bit process
	@set "PROC=64"
) else (
	@rem echo.32-bit process
	@set "PROC=32"
)
@goto done

:Win32
@rem echo.Windows 32-bit
@set "ARC=32"
@set "PROC=32"
@goto done

:DOS
@rem echo.DOS
@set "OS=DOS"
@set "ARC=16"
@set "PROC=16"
@goto done

:done
@echo OS: %OS%
@echo Architecture: %ARC%-bit
@echo Current process: %PROC%-bit
