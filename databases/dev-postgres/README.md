# dev-postgres
Create a Development PostgreSQL Docker container 

## Instructions

- Clone this repository using: 

  ```git clone https://github.com/ytrinh/dev-postgres project_dir```

- Run he refresh_db.sh script to create run the docker image

  ```cd project_dir && ./refresh_db.sh```
  
- Connect using the psql client using the id/pw of dev/dev:

  ```psql -h localhost -U dev -W dev```
  
- Make bootstrap/default database and schema changes in the follow:
  - `dev-db/init-db.sh`
  - `dev-db/sql/*`
  - `schema/*`
