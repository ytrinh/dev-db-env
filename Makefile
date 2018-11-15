.PHONY: show-help
help: show-help

docker-groups = $(subst .yml,,$(subst ./docker-compose-,,$(filter-out %-db.yml,$(wildcard ./docker-compose-*.yml))))

dev-env-head-hash=$(shell git rev-parse HEAD)
dev-env-remote-master-hash=$(shell git ls-remote origin master | cut -f1)

make-dir = ${CURDIR}

# by default, ignore the following components in the 'up' and 'start' target
GO_DEV_UP_IGNORE ?= ""

###
### build-images
###
.PHONY: build-images
build-images: 

###
### build images
###

###
### common
###
.PHONY: init
init: 
	-@cp -n .dockerignore ..
	make dev-databases
	make build-images
	@docker network ls | awk '{print $2}' | grep dev > /dev/null 2>&1 || docker network create dev

.PHONY: update
update: clone-projects
	make update-projects
	make go-packages
	make build-images

###
### compose actions
###
up: ignoreinfo $(foreach t,$(docker-groups), $(if $(findstring $t, $(GO_DEV_UP_IGNORE)), , up-$t))
#	@#sleep 10
#	@#cd keycloak && ./create-realm.sh
#	@echo "==============================================================================="
#	@echo "Reminder: "
#	@echo "    Go into ./keycloak/ and run create-realm.sh to create dev keycloak realm."
#	@echo "    You only need to do this for new DB container.  (i.e. after a 'down-db')"
#	@echo "==============================================================================="

    
.PHONY: ignoreinfo
ignoreinfo:
ifdef GO_DEV_UP_IGNORE
	@echo "==============================================================================="
	@echo "target is ignoring the following component(s): ${GO_DEV_UP_IGNORE}" 
	@echo " "
	@echo "   - set the env GO_DEV_UP_IGNORE to override this value"
	@echo "   - manualy bring up the ignored components using 'make up-???'"
	@echo "==============================================================================="
endif

down: $(foreach t,$(docker-groups), down-$t)

start: ignoreinfo $(foreach t,$(docker-groups), $(if $(findstring $t, $(GO_DEV_UP_IGNORE)), , start-$t))

stop: $(foreach t,$(docker-groups), stop-$t)

.PHONY: clean
clean:
	docker image prune -f

.PHONY: clean-images
clean-images: 
	docker image prune -f

.PHONY: rmi-%
rmi-%:
	-docker images --format '{{.ID}}' $* | xargs docker rmi -f
	-docker images --format '{{.ID}}' 249854217585.dkr.ecr.us-east-1.amazonaws.com/$* | xargs docker rmi -f

.PHONY: status
status:
	docker ps --format 'table {{.Status}}\t{{.Names}}\t{{.Size}}'

.PHONY: logs-%
logs-%: 
	@docker ps --format '{{.Names}}' | grep $* | xargs docker logs -f 

.PHONY: up-db
up-db:
	docker-compose -f docker-compose-db.yml -p "dev" up -d --remove-orphans
#	make after-db-up

.PHONY: up-%
up-%: up-db
	docker-compose -f docker-compose-$*.yml -p "$*" up -d --remove-orphans

.PHONY: down-db
down-db: down
	docker-compose -f docker-compose-db.yml -p "dev" down --remove-orphans

.PHONY: down-%
down-%: 
	docker-compose -f docker-compose-$*.yml -p "$*" down --remove-orphans

.PHONY: start-db
start-db: 
	docker-compose -f docker-compose-db.yml -p "dev" start

.PHONY: start-%
start-%: start-db
	docker-compose -f docker-compose-$*.yml -p "$*" start

.PHONY: stop-db
stop-db: stop
	docker-compose -f docker-compose-db.yml -p "dev" stop

.PHONY: stop-%
stop-%:
	docker-compose -f docker-compose-$*.yml -p "$*" stop

.PHONY: restart-%
restart-%: stop-% 
	make start-$*

.PHONY: refresh-%
refresh-%: down-% git-update-% 
	make check-dev-env
	make build-images-$*
	make up-$*

#.PHONY: after-db-up
#after-db-up:
#	@ cd ./after.db.up.d; \
#	for f in [0-9]*; do \
#	    echo "Running: $$f"; \
#	    [ -f "$$f" ] && [ -x "$$f" ] && "./$$f"; \
#	done



.PHONY: clone-projects
clone-projects: 

.PHONY: update-projects
update-projects: 
	make check-dev-env

.PHONY: git-clone-%
git-clone-%: 
	@ if [ ! -d "../$*" ]; then \
	    git clone git@github.com:ytrinh/$*.git ../$*; \
	fi

.PHONY: git-update-%
git-update-%: 
	@echo "git pull: $*"
	-@ if [ -d "../$*" ]; then \
	    cd ../$* && git pull; \
	fi

.PHONY: go-packages
go-packages:
	#git config --global http.https://gopkg.in.followRedirects true
	#go get -v github.com/rubenv/sql-migrate/...
	#go get -u github.com/goadesign/goa/...

.PHONY: dev-databases
dev-databases: dev-mysql dev-postgres dev-redis
	#$(MAKE) dev-mysql

.PHONY: dev-mysql
dev-mysql:
	cd databases/dev-mysql && docker build -f ./Dockerfile -t dev-mysql:latest . 

.PHONY: dev-postgres
dev-postgres:
	cd databases/dev-postgres && docker build -f ./Dockerfile -t dev-postgres:latest .

.PHONY: dev-redis
dev-redis:
	cd databases/dev-redis && docker build -f ./Dockerfile -t dev-redis:latest . 

.PHONY: mysql
mysql:
	docker exec -it pedb_mysql_1 /scripts/cli.sh

.PHONY: mysql-sh
mysql-sh:
	docker exec -it pedb_mysql_1 sh

.PHONY: psql
psql:
	docker exec -it pedb_postgres_1 /scripts/cli.sh

.PHONY: psql-sh
psql-sh:
	docker exec -it pedb_postgres_1 sh

.PHONY: redis
redis:
	docker exec -it pedb_redis_1 redis-cli

.PHONY: redis-sh
redis-sh:
	docker exec -it pedb_redis_1 sh

.PHONY: db-backup
db-backup:
	docker exec -it pedb_mysql_1 sh -c /scripts/backup.sh

.PHONY: db-restore
db-restore:
	docker exec -it pedb_mysql_1 sh -c /scripts/restore.sh

.PHONY: check-dev-env
check-dev-env: 
	@ if [ ! ${dev-env-head-hash} = ${dev-env-remote-master-hash} ]; then \
		echo "==========================================="; \
		echo "==========================================="; \
		echo "WARNING: Dev Makefile Env is not up to date"; \
		echo "==========================================="; \
		echo "==========================================="; \
	fi

.PHONY: prep-new-go-base
prep-new-go-base:
	cd ../docker-go-base && ./buildDocker.sh push
	docker save 249854217585.dkr.ecr.us-east-1.amazonaws.com/go-base:latest | gzip > go-base.tar.gz

.PHONY: load-go-base
load-go-base: 
	zcat < go-base.tar.gz | docker load

.PHONY: load-go-base
load-grpc-cli: 
	zcat < grpc-cli.tar.gz | docker load

.PHONY: git-statuses
git-statuses:
	cd .. && find . -maxdepth 1 -mindepth 1 -type d -exec sh -c '(echo {} && cd {} && [ -d .git ] && git rev-parse --symbolic-full-name --abbrev-ref HEAD && git status -s && echo)' \;

.PHONY: fix-time
fix-time:
	docker run --rm --privileged alpine hwclock -s

.PHONY: ctop
ctop:
	docker run -ti --name ctop --rm -v /var/run/docker.sock:/var/run/docker.sock quay.io/vektorlab/ctop:latest

.PHONY: show-help
show-help:
	@echo "======================================================================================="
	@echo "targets: "
	@echo "  init:         initialize enviroment by creating Docker images and checking out projects"
	@echo "  update:       update application containers"
	@echo "  clean:        remove old orphan images"
	@echo "  clean-images: remove images created for aws and remove old orphan images"
	@echo " "
	@echo "  mysql:        Start mysql prompt for dbpe_mysql_1 container"
	@echo "  redis:        Start redis-cli prompt for dbpe_redis_1 container"
	@echo " "
	@echo "  up-db:        Bring up mysql, redis, etc."
	@echo "  down-db:      Bring down mysql, redis, etc.: WARNING: you WiLL lose data!"
	@echo "  start-db:     Start mysql, redis, etc."
	@echo "  stop-db:      Stop mysql, redis, etc."
	@echo " "
	@echo "  up:           Bring up all applications"
	@echo "  down:         Remove all applications containers"
	@echo "  start:        Start all applications containers"
	@echo "  stop:         Stop all applications containers"
	@echo "  "
	@echo "The following targets are also supported: \n"
	@for s in $(docker-groups); do \
		echo "$$s"; \
		echo "  up-$$s, down-$$s, start-$$s, stop-$$s, restart-$$s, refresh-$$s\n"; \
	done
	@echo "======================================================================================="
	@echo "Options:"
	@echo "   - GO_DEV_UP_IGNORE - Set this env var with a list of items to ignore for 'up' target"
	@echo "       current value: $$GO_DEV_UP_IGNORE"
	@echo "  "
	@echo "======================================================================================="
	@echo "Local Container Database connect info:"
	@echo "  mysql: "
	@echo "         mysql --host=127.0.0.1 --port=3306 --user=root dev"
	@echo "         psql -h localhost -p 5432 -U dev dev"
	@echo "  "
	@echo "  redis:"
	@echo "         redis-cli -h localhost -p 6379"
	@echo "  "
	@echo "======================================================================================="
	@echo "Web apps entry point:"
	@echo "  myadmin :           http://localhost:8081             login: root/root"
	@echo "  mailhog :           http://localhost:8025"
	@echo "======================================================================================="
