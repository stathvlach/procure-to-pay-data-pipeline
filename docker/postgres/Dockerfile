FROM postgres:16-alpine

ENV POSTGRES_DB=nano_mm \
    POSTGRES_USER=nano_mm_user \
    POSTGRES_PASSWORD=changeme

# Create app-level data directories
RUN mkdir -p /data/landing \
             /data/staging \
             /data/warehouse && \
    chown -R postgres:postgres /data

VOLUME ["/data"]

# Init SQL scripts
COPY sql/ddl/*.sql   /docker-entrypoint-initdb.d/

