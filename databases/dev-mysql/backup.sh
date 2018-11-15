#!/bin/bash

mysqldump --user="$MYSQL_USER" --password="$MYSQL_PASSWORD" $MYSQL_DATABASE > /pe/dev-mysql-backup.sql
