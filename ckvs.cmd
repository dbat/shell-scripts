@echo off

@setLocal enableExtensions enableDelayedExpansion
@echo.Script to check vs installation

@set refdll=
@set ver=0

@for %%f in (
	msvcp???.dll
	msobj???.dll
	pgodb???.dll
	mspdb???.dll
	msvcr???.dll
	vcamp???.dll
) do if !ver! lss 5 (
	set refdll=%%~nf
	set /a ver="!refdll:~5!" +0
)

@echo dllref="%refdll%" ver=%ver%

@if %ver% lss 50 goto done_pause

rem goto done_pause

:start
set asm=ml;$ml64;lib;link;dumpbin;editbin;@cl;
set dll=msdis;mspdb;msvcr;pgodb;
set cpp=@c1;@c1ast;@c1xx;@c1xxast;@c2;
set dep=@vcomp;@atlprov;@msobj;@msvcp;
set diropts=/b /r /a-d


set model=%~1
if "%model%"=="" set model=flat

::set them to c/c++ dir

echo model=%model%
goto model_%model%

:model_cpp
set asm=%asm:$=x86_amd64\%
set asm=%asm:@=cpp\%
set cpp=%cpp:@=cpp\%
set dep=%dep:@=cpp\%
goto expand


:model_flat
set asm=%asm:$=x86_amd64\%
set asm=%asm:@=.\%
set cpp=%cpp:@=.\%
set dep=%dep:@=.\%
goto expand


:model_bincpp
set asm=%asm:$=x86_amd64\%
set asm=%asm:@=..\bin.cpp\%
set cpp=%cpp:@=..\bin.cpp\%
set dep=%dep:@=..\bin.cpp\%
goto expand


:expand
set asms=%asm:;=.exe %
set cpps=%cpp:;=.dll %
set dlls=%dll:;=*.dll %
set deps=%dep:;=*.dll %

set asms=%asms:~0,-1%
set dlls=%dlls:~0,-1%
set cpps=%cpps:~0,-1%
set deps=%deps:~0,-1%

goto begin

echo.
echo asm=[%asm%]
echo.dll=[%dll%]
echo.cpp=[%cpp%]
echo.dep=[%dep%]

echo.
echo asms=[%asms%]
echo.cpps=[%cpps%]
echo.dlls=[%dlls%]
echo.deps=[%deps%]

:begin
echo.&echo.Core asm:
dir %diropts% %asms% 2>nul | find ".exe"
echo.missing:
for %%f in (%asm%) do if not exist %%f*.exe echo.  %%f.exe

echo.&echo.C/C++:
dir %diropts% %cpps% 2>nul | find ".dll"
echo.missing:
for %%f in (%cpp%) do if not exist %%f*.dll echo.  %%f.dll

echo.&echo.Main dependencies:
dir %diropts% %dlls% 2>nul | find ".dll"
echo.missing:
for %%f in (%dll%) do if not exist %%f*.dll echo.  %%f.dll

echo.&echo.Additional C/C++ dependencies:
dir %diropts% %deps% 2>nul | find ".dll"
echo.missing:
for %%f in (%dep%) do if not exist %%f*.dll echo.  %%f.dll

echo.&echo.Unnecessary extra mfc's files, should be moved to shared or nul:
for %%f in (makehm* guidgen* errloo* atl[ver]* mfc*) do echo %%~nxf
echo.

:done
goto chk_%model%
goto done2

:chk_flat
echo.C/C++ tools:
for %%f in (*) do (
	set found=
	for %%g in (%asm% %dlls% %cpps% %deps%) do if not defined found if "%%~sf"=="%%~sg" set found=1
	if not defined found echo %%~nxf
	)
goto done2

:chk_cpp
goto done2

:chk_bincpp
goto done2

goto done2

:done2


:done_pause
pause

:eof

