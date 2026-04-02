@echo off
setlocal enabledelayedexpansion

echo.
echo === CLEAN RESET ===
echo [1/7] Stopping containers and removing volumes...
docker compose down -v
echo [2/7] Recreating Airflow directories...
if not exist airflow\dags mkdir airflow\dags
if not exist airflow\logs mkdir airflow\logs
if not exist airflow\plugins mkdir airflow\plugins

echo.
echo === START DATABASE ===
echo [3/7] Starting PostgreSQL and showing init logs...
docker compose up --build -d db

REM Start logs in a separate window and capture the PID concept differently
echo [Monitoring PostgreSQL health...]
set /a max_attempts=60
set /a attempt=0

:health_check_loop
docker inspect --format="{{.State.Health.Status}}" nano-mm-db >nul 2>&1
if errorlevel 1 (
    if !attempt! lss !max_attempts! (
        timeout /t 2 /nobreak >nul
        set /a attempt=!attempt!+1
        goto health_check_loop
    ) else (
        echo ERROR: PostgreSQL failed to become healthy
        exit /b 1
    )
)

timeout /t 7 

REM Verify it's actually healthy
docker inspect --format="{{.State.Health.Status}}" nano-mm-db | findstr /i "healthy" >nul
if errorlevel 1 (
    echo ERROR: PostgreSQL is not healthy
    exit /b 1
)

echo PostgreSQL is healthy.
echo.

echo === AIRFLOW INIT ===
echo [4/7] Initializing Airflow...
docker compose run --rm airflow-init
if errorlevel 1 (
    echo ERROR: Airflow initialization failed
    exit /b 1
)
echo.

echo === START AIRFLOW ===
echo [5/7] Starting Airflow webserver...
docker compose up -d airflow-webserver
if errorlevel 1 (
    echo ERROR: Failed to start Airflow webserver
    exit /b 1
)

echo [6/7] Starting Airflow scheduler...
docker compose up -d airflow-scheduler
if errorlevel 1 (
    echo ERROR: Failed to start Airflow scheduler
    exit /b 1
)
echo.

echo [7/7] Showing running services...
docker compose ps
echo.

echo === DONE ===
echo Airflow UI: http://localhost:8080
echo Username: airflow
echo Password: airflow

endlocal