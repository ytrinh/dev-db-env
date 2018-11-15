# DB docker env
Database running under docker for dev

Prerequisite
============

- Docker machine
- make
- curl
- jq

Initialization
==============

- Run `make init` to initialize the DB images
- Run `make up` to bring up the DB docker services

Starting/Stopping
=================

- Run `make stop stop-db` to stop the docker DB services
- Run `make start-db start` to start the docker DB services

Shutdown
========

Bringing the DB docker images down will remove all database data.  Do this only if you want to 'refresh' the database.

- Run `make down` to bring down all non db services
- Run `make down-db` to bring down databases

Help
====

- Run `make help` to get additional env and target information
