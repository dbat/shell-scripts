@echo off
setlocal enableextensions enabledelayedexpansion
set echo=
if /i "%~1"=="-d" set echo=@echo & shift
if /i "%~1"=="/d" set echo=@echo & shift

goto START

:Help
@echo OFF
echo.
echo. Copyright 2003-2009 PT SOFTINDO, Jakarta
echo. Version: 20130711
echo.
echo. Batch script to get tar.gz packages from github
echo. Requires: WGET+SSL
echo.
echo. Usage:
echo.     %~n0 http://www.github.com/User_name/Repo_name
echo.
echo.   or just
echo.
echo.     %~n0 User_name/Repo_name (this part is CaSe SeNSiTiVe)
echo.
exit /b
echo. to get archive file from github
echo. wget --no-check-certificate https://github.com/User/repo/archive/master.tar.gz

:START
if defined echo echo on
if "%~1"=="" goto Help

set "ARG=%~1"

::rem check whether is it a url fullpath
if "%ARG:://=%"=="%ARG%" goto goon1

::rem don't use uppercase for hostname
set "ARG=%ARG:*github.com/=%"
set "ARG=%ARG:*GITHUB.COM/=%"

if not "%ARG%"=="%~1" goto goon1
@echo.
@echo.ERROR Unknown server: %ARG%
goto Help
exit /b

:goon1
set "REPO=%ARG:*/=%"
if "%REPO%"=="%ARG%" goto Help

set "USER=!ARG:/%REPO%=!"
if "%USER%"=="%ARG%" goto Help

set "URL=https://github.com"
set "FETCH=curl"
set "OPT1=--location --insecure -A Mozilla/4.1 --silent"
set "OPT2=-o "%USER%-%REPO%.tgz""
@if defined echo exit /b

<nul set/p= Fetching %REPO%.tgz..
%FETCH% %OPT1% %OPT2% https://github.com/%USER%/%REPO%/archive/master.tar.gz
echo.. done.
