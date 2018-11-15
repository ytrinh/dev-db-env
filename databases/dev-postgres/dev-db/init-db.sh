#!/bin/bash
set -e

cd /docker-entrypoint-initdb.d/

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -f ./sql/create_db.sql

PGPASSWORD=dev psql -v ON_ERROR_STOP=1 --username "dev" --dbname=dev -f ./schema/schema.sql

PGPASSWORD=dev psql -v ON_ERROR_STOP=1 --username "dev" --dbname=dev -f ./schema/data.sql
