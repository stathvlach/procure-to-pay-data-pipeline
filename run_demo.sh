#!/bin/bash

set -e

echo ""
echo "=== CLEAN RESET ==="
echo "[1/8] Stopping containers and removing volumes..."
docker compose down -v

echo "[2/8] Recreating Airflow directories..."
mkdir -p airflow/logs
mkdir -p airflow/plugins

echo ""
echo "=== START DATABASE ==="
echo "[3/8] Starting PostgreSQL and showing init logs..."
docker compose up --build -d db

echo "[Monitoring PostgreSQL health...]"
max_attempts=60
attempt=0

while [ $attempt -lt $max_attempts ]; do
    health_status=$(docker inspect --format="{{.State.Health.Status}}" nano-mm-db 2>/dev/null || echo "unknown")
    
    if [ "$health_status" = "healthy" ]; then
        break
    fi
    
    if [ $attempt -lt $max_attempts ]; then
        sleep 3
        echo "waiting..."
        ((attempt++))
    else
        echo "ERROR: PostgreSQL failed to become healthy"
        exit 1
    fi
done

sleep 7

if ! docker inspect --format="{{.State.Health.Status}}" nano-mm-db | grep -qi "healthy"; then
    echo "ERROR: PostgreSQL is not healthy"
    exit 1
fi

echo "PostgreSQL is healthy."
echo ""

echo "=== ADMINER INIT ==="
echo "[4/8] Initializing Adminer..."
if ! docker compose up -d adminer; then
    sleep 3
    exit 1
fi

echo ""
echo "=== AIRFLOW INIT ==="
echo "[5/8] Initializing Airflow..."
if ! docker compose run --rm airflow-init; then
    echo "ERROR: Airflow initialization failed"
    exit 1
fi

echo ""
echo "=== START AIRFLOW ==="
echo "[6/8] Starting Airflow webserver..."
if ! docker compose up -d airflow-webserver; then
    echo "ERROR: Failed to start Airflow webserver"
    exit 1
fi

echo "[7/8] Starting Airflow scheduler..."
if ! docker compose up -d airflow-scheduler; then
    echo "ERROR: Failed to start Airflow scheduler"
    exit 1
fi

echo ""
echo "[8/8] Showing running services..."
docker compose ps

echo ""
echo "=== DONE ==="
echo "Opening Airflow UI..."

while true; do
    if curl -s http://localhost:8080 > /dev/null 2>&1; then
        break
    fi
    echo "waiting..."
    sleep 4
done

docker exec -it airflow-scheduler airflow dags unpause operational_schema_setup
docker exec -it airflow-scheduler airflow dags trigger operational_schema_setup
docker exec -it airflow-scheduler airflow dags unpause populate_purchase_orders

if command -v xdg-open &> /dev/null; then
    xdg-open "http://localhost:8080" &
    sleep 1
    xdg-open "http://localhost:8081/?pgsql=db&username=nano_mm&db=nano_mm&ns=operational&schema=" &
elif command -v open &> /dev/null; then
    open "http://localhost:8080"
    sleep 1
    open "http://localhost:8081/?pgsql=db&username=nano_mm&db=nano_mm&ns=operational&schema="
else
    echo "Note: Could not open browser automatically (xdg-open not found)"
    echo "Open these URLs manually:"
fi

echo "Username/Password: admin/admin"
echo "Opening Adminer UI..."
echo "Username/Password: nano_mm/nano_mm"