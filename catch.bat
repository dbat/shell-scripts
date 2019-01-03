@if "%~1"=="" exit /b
@for /f "usebackq" %%f in (`where "%~1"`) do @if exist "%%f" echo.&echo.::%%f&type "%%f"
