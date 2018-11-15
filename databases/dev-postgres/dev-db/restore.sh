#!/bin/bash

PGPASSWORD=dev psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname=dev < /pe/dev-pg-backup.sql

