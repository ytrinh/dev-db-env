FROM postgres:11.1-alpine

LABEL authors="Yung Trinh"

ENV POSTGRES_USER postgres
ENV POSTGRES_PASSWORD postgres

COPY dev-db/init-db.sh /docker-entrypoint-initdb.d/
COPY dev-db/cli.sh /scripts/cli.sh
COPY dev-db/backup.sh /scripts/backup.sh
COPY dev-db/restore.sh /scripts/restore.sh
COPY dev-db/sql /docker-entrypoint-initdb.d/sql
COPY schema /docker-entrypoint-initdb.d/schema

RUN cd /docker-entrypoint-initdb.d/ \
  && chmod +x init-db.sh \
  && chmod +x /scripts/cli.sh \
  && chmod +x /scripts/backup.sh \
  && chmod +x /scripts/restore.sh

