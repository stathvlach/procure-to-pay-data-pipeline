#!/usr/bin/env bash
set -euo pipefail

echo
echo "=== CLEAN RESET ==="

echo "[1/7] Stopping containers and removing volumes..."
docker compose down -v

echo "[2/7] Recreating Airflow directories..."
mkdir -p airflow/dags airflow/logs airflow/plugins

echo
echo "=== START DATABASE ==="

echo "[3/7] Starting PostgreSQL and showing init logs..."
docker compose up --build -d db

docker logs -f nano-mm-db &
DB_LOG_PID=$!

until [ "$(docker inspect --format='{{.State.Health.Status}}' nano-mm-db 2>/dev/null || true)" = "healthy" ]; do
  sleep 2
done

kill "$DB_LOG_PID" 2>/dev/null || true
wait "$DB_LOG_PID" 2>/dev/null || true

echo "PostgreSQL is healthy."

echo
echo "=== AIRFLOW INIT ==="

echo "[4/7] Initializing Airflow..."
docker compose run --rm airflow-init

echo
echo "=== START AIRFLOW ==="

echo "[5/7] Starting Airflow webserver..."
docker compose up -d airflow-webserver

echo "[6/7] Starting Airflow scheduler..."
docker compose up -d airflow-scheduler

echo
echo "[7/7] Showing running services..."
docker compose ps

echo
echo "=== DONE ==="
echo "Airflow UI: http://localhost:8080"
echo "Username: airflow"
echo "Password: airflow"
