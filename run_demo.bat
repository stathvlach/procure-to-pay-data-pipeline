@echo off
setlocal enabledelayedexpansion

echo.
echo === CLEAN RESET ===
echo [1/8] Stopping containers and removing volumes...
docker compose down -v

echo [2/8] Recreating Airflow directories...
if not exist airflow\logs mkdir airflow\logs
if not exist airflow\plugins mkdir airflow\plugins

echo.
echo === START DATABASE ===
echo [3/8] Starting PostgreSQL and showing init logs...
docker compose up --build -d db

REM Start logs in a separate window and capture the PID concept differently
echo [Monitoring PostgreSQL health...]
set /a max_attempts=60
set /a attempt=0

:health_check_loop
docker inspect --format="{{.State.Health.Status}}" nano-mm-db >nul 2>&1
if errorlevel 1 (
    if !attempt! lss !max_attempts! (
        timeout /t 3 /nobreak >nul
		echo waiting...
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

echo === ADMINER INIT ===
echo [4/8] Initializing Adminer...
docker compose up -d adminer
if errorlevel 1 (
    timeout /t 3 >nul
    exit /b 1
)
echo.

echo === AIRFLOW INIT ===
echo [5/8] Initializing Airflow...
docker compose run --rm airflow-init
if errorlevel 1 (
    echo ERROR: Airflow initialization failed
    exit /b 1
)
echo.

echo === START AIRFLOW ===
echo [6/8] Starting Airflow webserver...
docker compose up -d airflow-webserver
if errorlevel 1 (
    echo ERROR: Failed to start Airflow webserver
    exit /b 1
)

echo [7/8] Starting Airflow scheduler...
docker compose up -d airflow-scheduler
if errorlevel 1 (
    echo ERROR: Failed to start Airflow scheduler
    exit /b 1
)
echo.

echo [8/8] Showing running services...
docker compose ps
echo.

echo === DONE ===
echo Opening Airflow UI...

:wait_airflow
curl -s http://localhost:8080 >nul 2>&1
if errorlevel 1 (
	echo waiting...
    timeout /t 4 >nul
    goto wait_airflow
)

docker exec -it airflow-scheduler airflow dags unpause operational_schema_setup
docker exec -it airflow-scheduler airflow dags trigger operational_schema_setup

docker exec -it airflow-scheduler airflow dags unpause populate_purchase_orders

start "" "http://localhost:8080"

echo Username/Password: admin/admin

echo Opening Adminer UI...

start "" "http://localhost:8081/?pgsql=db&username=nano_mm&db=nano_mm&ns=operational&schema="

echo Username/Password: nano_mm/nano_mm

endlocal