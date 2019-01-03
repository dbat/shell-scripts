@echo OFF
setLocal enableExtensions enableDelayedExpansion
set LOG=%~n1_wget.log
wget -U GoZilla/1.0 -bc -nH -np --no-check-certificate --no-remove-listing --progress=dot:mega -a %LOG% %*

