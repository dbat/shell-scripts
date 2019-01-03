@echo OFF
setLocal enableextensions
::===========================
set "IMGX=e:\programs\imgx"
::===========================
set "_DEFAULT_WILCARD_=*.jpg"
set "_DEFAULT_DESTDIR_=straighten"
set "HelpMe="
set "echo="

goto START

:Help
@echo. 
@echo. batch file to straighten images
@echo. version 2015.01.01
@echo. 
@echo. usage:	%~n0 -go [ wildcards ] [ DESTDIR ]
@echo. 
@echo. 	default wildcards is: "%_DEFAULT_WILCARD_%"
@echo. 	default dest. dir is: "%_DEFAULT_DESTDIR_%"
@echo. 
@echo. 	current wildcards is: "%JPGs%"
@echo. 	current dest. dir is: "%dstdir%"
@echo. 
@echo. requires: imagemagick in IMGX = "%IMGX%"
goto:eof

:START
set "SRCDIR=%CD%"
set "DSTDIR=%_DEFAULT_DESTDIR_%"
set "JPGs=%_DEFAULT_WILCARD_%"

for %%a in (- /) do if /i "%~1"=="%%a?" goto Help
for %%a in (-h --help /h /help) do if /i "%~1"=="%%a" goto Help

if not "%~1"=="-go" (set "HelpMe=1" & set "echo=@echo" ) else shift

if not "%~2"=="" set "DSTDIR=%~2"
if not exist "%dstdir%"\ %echo% md "%dstdir%"
for %%f in ("%dstdir%") do set "dstdir=%%~dpnxf"

::@rem must be done after getting old CD and creating desdir
pushd "%IMGX%" || ( set "IMGX=dir not found" & goto:Help )

if not "%~1"=="" set "JPGs=%~1"

set "k=0"
set "r=0"
set "n=0"
::echo on

for %%f in ("%srcdir%\%JPGs%") do (
  if not exist "%dstdir%\%%~nf.jpg" (
    set /a "n=!n!+1"
    if not defined echo @echo.Converting "%%~nxf"..
    %echo% convert "%%f" -deskew 40%% -quality 80%% "%dstdir%\%%~nf.jpg"
  ) else (
    echo. skipping %%~nf.jpg.. already exist
  )
)

if defined HelpMe goto Help

if %n% gtr 0 ( set "n= processing %n% file(s)" ) else set "n="
if %k% gtr 0 set "n=%n%, %k% file(s) skipped"
@echo.Done%n%.

::@rem convert SOURCE.img -resize 16.667% -resize 600% -threshold 67% -resize 25% -quality 80% TARGET.img
::@rem magick convert SOURCE.jpg -deskew 60% -format "%[deskew:angle]" info:
::@rem magick convert SOURCE.jpg -set filename:f "%t" -background black -fuzz 75% -deskew 50% -trim +repage out/%[filename:f]_cropped.png;
::@rem magick convert SOURCE.jpg -set filename:f "%t" -background yellow -fuzz 80% -deskew 50% -trim +repage CROPDIR/%[filename:f]_cropped.jpg;

::popd

