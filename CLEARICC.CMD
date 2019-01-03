@echo OFF
:: Clear icon cache without reboot
setLocal enableExtensions enableDelayedExpansion
set ie4uinit=%windir%\system32\ie4uinit.exe
if not exist "%ie4uinit%" set ie4uinit=%windir%\sysnative\ie4uinit.exe

%ie4uinit% -ClearIconCache
