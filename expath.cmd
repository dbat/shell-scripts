@if "%~1"=="" @echo.%PATH:;=&@echo.% & exit /b
@if not "%~1"=="-q" exit /b
@echo OFF

@echo."%PATH:;="&@echo."%"
