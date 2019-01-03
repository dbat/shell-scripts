@echo OFF
@setLocal enableExtensions
@goto START

:Help
@echo.  @20091006
@echo.
@echo.  Batch script to enumerate dependencies
@echo.  Requires: LINK, FINDSTR, SORT. Optional: UNIQ
@echo.
@echo.  Usage:
@echo.      %~n0 [ -s ^| -a ] files..
@echo.
@echo.  Arguments:
@echo.      files (mandatory): Files/filemasks (*, ??.dll) to be enumerated.
@echo.
@echo.      -s (optional):	Show summary only.
@echo.
@echo.      -a (optional):	Process all arguments at once, with one golbal
@echo. 			summary, otherwise there will one sub summary
@echo 			per-argument.
goto EOF


:START
@set A1=%~1
@if not defined A1 goto Help

@rem set temporary file
@set rtmp=%TEMP%\d11_%RANDOM%_%RANDOM%

@set "LINK=link.exe"

@set "PathtoVS=%~dp0vs"
if exist "%PathtoVS%\link.exe" (
  rem set "pp="
  rem for %%f in (lib.exe) do set pp=%%~$PATH:f
  rem if not defined pp set path=%PathtoVS%;%PATH%
  set "LINK=%PathtoVS%\link.exe"
)


:begin
@rem search for uniq
@for %%f in (uniq.exe) do set UNIQ=%%~$PATH:f

@rem excluded dependencies, customize them as your convenience
@set msapi=api-ms-
@set excludes=mscoree advapi32 version psapi rpcrt4 ntdll kernel32 shell32 user32 ole32 oleaut32 %msapi%

::------------------------------------
:: Clear them here to show all noises
::------------------------------------
::@set msapi=
::@set excludes=

@set procAll=
@set SumOnly=

@set A1=%*
@if "%~1%"=="-a" set procAll=1 & goto proceed
@if "%~1%"=="-s" set SumOnly=1 & goto proceed

:LOOP
@set A1=%1
@if not defined A1 goto done

:proceed
"%LINK%" -dump /nologo /dependents %A1% | findstr /i "^dump : .dll$" | findstr /v "Type: %msapi%" > "%rtmp%"
@if not defined SumOnly @echo.&type "%rtmp%"

@rem get DLL only
findstr /i ".dll" "%rtmp%" | findstr /i /r /v "^dump : %excludes%" > "%rtmp%"_1

for %%f in ("%rtmp%_1") do if %%~zf lss 8 goto Cleanup

@rem sort, and uniq if available
@if not defined UNIQ (
	sort "%rtmp%"_1 > "%rtmp%"
	) else (
	sort "%rtmp%"_1 | "%UNIQ%" > "%rtmp%"
)

:Summary
@echo.
@for /f "usebackq" %%f in ("%rtmp%") do (
	@if not exist "%%~$PATH:f" (
		@echo.missing	%%f
	) else (
		@if exist "%%f" (
			@echo.found	%%f
		) else (
			@echo.found	%%~$PATH:f
		)
	)
)

:Cleanup
::echo rtmp=%rtmp%
@del /q "%rtmp%" "%rtmp%"_1

@if defined SumOnly goto done
@if defined procAll goto done

@shift
@goto LOOP
@goto done

:done
@echo.

:EOF
