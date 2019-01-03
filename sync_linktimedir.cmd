@echo OFF
setLocal enableExtensions enableDelayedExpansion
goto START

:ShowHelp
echo.
echo. sync link time with the file it refers to
echo. also update directory time with it's .iso content
echo. format: drahscotl (https://ss64.com/nt/syntax-args.html)
echo.
echo. requires: toucher.exe (https://www.github.com/dbat/toucher) 
echo.
pause
exit/b


:do_toucher
  for %%i in (%~1) do (
    %echo%  toucher -lr "%%i" . index.html
    exit /b
  )
exit /b

:do_exams
  for %%x in (iso inf txt gz) do (
    if exist *.%%x (
       call :do_toucher "*.%%x"
       exit /b
    )
  )

  for %%f in (*) do (
    if /i not "%%f"=="index.html" (
      call :do_toucher "%%f"
      exit /b
    )
  )

  for /d %%d in (*) do (
    call :do_toucher "%%d"
    exit /b
  )
exit /b


:START
set "echo="
if not "%~1"=="-go" set "echo=echo"

set "toucher="
for %%f in (toucher.exe) do set "toucher=%%~$PATH:f"

if not defined toucher echo. ERROR: can not found toucher.exe & goto ShowHelp

:: note that all directories here are real / not a symlink
:: and all their contents are symlinks

set "tempfile=%temp%\_dt_%RANDOM%_"
echo.>"%tempfile%"

for /d %%d in (*) do (
  pushd "%%d"
  cd
  for %%f in (*) do (
    set "attr=%%~af"
    set "att9=!attr:~-1!"
    if /i "!att9!"=="l" (
      %echo%  toucher -r "%%f" "%tempfile%"
      %echo%  toucher -lr "%tempfile%" "%%f"
    )
  )

  rem inner break loop doesn't work well on cmd
  rem
  rem  for %%x in (iso inf txt) do (
  rem    if exist *.%%x (
  rem       call :do_toucher "*.%%x"
  rem       break
  rem    ) else call :do_toucher "*"
  rem  )
  rem
  rem if exist *.iso (
  rem   call :do_toucher "*.iso"
  rem ) else (
  rem   echo. WARNING: Can not found .iso archive
  rem   echo.          Using any file as time reference
  rem   if exist *.inf (
  rem      call :do_toucher "*.inf"
  rem   ) else (
  rem     if exist *.txt (
  rem       call :do_toucher "*.txt"
  rem     )
  rem   )
  rem )
  rem
  rem inner break loop doesn't work well on cmd

  call :do_exams

  popd
)

del /q "%tempfile%" > nul

:STOP
