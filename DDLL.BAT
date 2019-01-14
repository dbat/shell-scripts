@echo OFF
::@echo ON
@setLocal enableExtensions

set "LINK=link.exe"

set "PathtoVS=%~dp0vs"
if exist "%PathtoVS%\link.exe" (
  rem set "pp="
  rem for %%f in (lib.exe) do set pp=%%~$PATH:f
  rem if not defined pp set path=%pathtovs%;%PATH%
  set "LINK=%PathtoVS%\link.exe"
)

@rem -- if defined VCBIN if not "%VCBIN:~-1%"=="/" set VCBIN=%VCBIN%/
@goto START

:Help
@echo.  @20101010
@echo.
@echo.  SYNOPSYS:
@echo.	Enumerate object binary dependencies (exe/dll/sys etc.)
@echo.
@echo.  REQUIRES:
@echo.	VS\LINK.EXE (functional, with it's dependencies)
@echo.	FINDSTR.EXE (native utility in %%windir%%\system32)
@echo.	SORT.EXE (either native or UNIX's sort will do)
@echo.	(Optional/autodetect: UNIQ.EXE when available)
@echo.
@rem -- @echo.		VCBIN should be set to a valid LINK.EXE's PATH
@rem -- @echo.		to avoid name conflict with another LINK.EXE
@rem -- @echo.		(usually it's in Visual Studios' VC\bin directory)
@rem -- @echo.
@rem -- set exestatus=OK
@rem -- if not exist "%VCBIN%"link.exe set exestatus=invalid
@rem -- @echo.  VCBIN="%VCBIN%" (%exestatus%)
@rem -- @echo.
@echo.  USAGE:
@echo.	%~n0 [ /v ] [ /s ^| /a ] files..
@echo.
@echo.    Mandatory argument:
@echo.
@echo.        files:	Files/filemasks (*, ??.dll) to be enumerated.
@echo.
@echo.	If filemask is not a glob (?, *) and it IS a directory,
@echo.	then all files under that directory will be enumerated
@rem - @echo.	(and search PATH appended for that directory.)
@echo.	(Does not work with /a or /s switch. See notes below)
@echo.
@echo.    Optional arguments:
@echo.
@echo.        /v :	Verbose, don't skip common DLLs (user, kernel etc.)
@echo.		or MS-API- dependency noise
@echo.
@echo.        /s :	Show summary only.
@echo.
@echo.        /a :	Process all arguments at once, one global summary
@echo. 		(otherwise there will one sub summary per-argument).
@rem - @echo.		(Note: effective for multiple arguments only)
@echo.		
@echo.  NOTES:
@echo.	When LINK.EXE encounter a fatal error, for example,
@echo.	processing zero size file, batch process terminated
@echo.	prematurely before it had a chance to process all files.
@echo.	(Checking for size is unfeasible for wildcard/glob).
@echo.
@echo.	You have to remove or skip the offending files first.
@echo.
@echo.	When given switch /a or /s, all arguments fed directly
@echo.	to LINK.EXE, directory auto-detection can't be processed.
@echo.
@echo.	If UNIQ.EXE is not available, there might be multiple
@echo.	entries in the summary.
goto EOF


:START
@set A1=%~1
@if not defined A1 goto Help

@rem -- if not exist "%vcbin%"\link.exe (
@rem --   echo.  =====================================================================
@rem --   echo.  ERROR^!	VCBIN environment variable is undefined or invalid
@rem --   echo.       		VCBIN MUST be set to Visual Studio's VC\BIN directory
@rem --   echo.
@rem --   echo.  Example:	SET VCBIN=C:\Program Files\Visual Studio 9\VC\bin
@rem --   echo.  =====================================================================
@rem --   goto Help
@rem -- )


@rem set temporary file
@set rtmp=%TEMP%\d11_%RANDOM%_%RANDOM%

:begin
@rem search for uniq
@for %%f in (uniq.exe) do set UNIQ=%%~$PATH:f
@rem echo.UNIQ=%uniq%

::---------------------------------------
::@rem excluded dependencies for display,
::@rem change them as your convenience
::---------------------------------------
@set "msapi=api-ms-"
@set "excludes=mscoree advapi32 version psapi rpcrt4 ntdll kernel32 shell32 user32 ole32 oleaut32 %msapi%"

@if not "%~1%"=="/v" goto CheckArg2
shift
@set "msapi="
@set "excludes="

:CheckArg2
@set A1=%*

@rem strip arguments string
@set A1=%A1:/a=%
@set A1=%A1:/s=%
@set A1=%A1:/v=%

@set procAll=
@set SumOnly=
@if "%~1%"=="/a" set procAll=1 & goto proceed
@if "%~1%"=="/s" set SumOnly=1 & goto proceed

set "OLDPATH=%PATH%"

:LOOP
set "PATH=%OLDPATH%"

@set A1=%~1
@if not defined A1 goto done

set A1=%1

set SHORT=%~s1
set c=%SHORT:~-1%

set "PDIR="
if not "%c%"=="." if exist %~s1\nul (
	set PDIR=%~1
	set "PATH=%PATH%;%1"
	set A1=%1\*
)

:proceed
rem "%LINK%" -dump /nologo /dependents %A1% | findstr /i "^dump : .dll$" | findstr /v "Type: %msapi%" > "%rtmp%"
"%LINK%" -dump /dependents %A1% | findstr /i "^dump : .dll$" | findstr /i /v "Type: %msapi%" > "%rtmp%"
@if not defined SumOnly @echo.&type "%rtmp%"

@rem get DLL only
findstr /i ".dll" "%rtmp%" | findstr /i /r /v "^dump : %excludes%" > "%rtmp%"_1

for %%f in ("%rtmp%_1") do if %%~zf lss 8 goto Cleanup

@rem sort, and uniq if available
@if not defined UNIQ (
	sort "%rtmp%"_1 > "%rtmp%"
	) else (
	sort "%rtmp%"_1 | "%UNIQ%" -i > "%rtmp%"
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
			@if exist "%PDIR%\%%f" (
				@echo.found	%PDIR%\%%f
			) else (
				@echo.found	%%~$PATH:f
			)
		)
	)
)

:Cleanup
::echo rtmp=%rtmp%
::pause
@del /q "%rtmp%" "%rtmp%"_1

@if defined SumOnly goto done
@if defined procAll goto done

@shift
@goto LOOP
@goto done

:done
@echo.

:EOF
