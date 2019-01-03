@echo OFF
setLocal enableExtensions enableDelayedExpansion
:: arg1 must be either enable or disable

goto START

:: list the interfaces
:: note: an interface could be listed identically twice
::       if detached and reattached to a different slot
wmic nic get name, index
wmic path win32_networkadapter where adaptertypeid=0

:: use its index to enable/disable the interface
wmic path win32_networkadapter where index=7 call enable
wmic path win32_networkadapter where index=11 call disable

:HELP
echo.
echo. Usage: %~n0 [index] [switch]
echo.
echo. 	index:	id number of device from the list
echo. 	switch:	either enable or disable
echo.

wmic nic get name, index
goto EOF

:START
if "%~1"=="" goto HELP
if /i "%~1"=="list" goto HELP

:BEGIN
if not "%~2"=="" goto arg2
goto HELP
::goto arg1


:arg1
wmic path win32_networkadapter where index=11 call %~1
goto EOF

:arg2
wmic path win32_networkadapter where index=%~1 call %~2
goto EOF




:EOF
