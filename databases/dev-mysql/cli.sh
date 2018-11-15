#!/bin/bash

mysql --user="$MYSQL_USER" --password="$MYSQL_PASSWORD" -h 127.0.0.1 $MYSQL_DATABASE
