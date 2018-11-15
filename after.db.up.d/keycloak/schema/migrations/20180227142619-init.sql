-- +migrate Up
create schema if not exists keycloak CHARACTER SET = utf8 COLLATE = utf8_unicode_ci;
create user if not exists 'keycloak'@'localhost' identified by 'keycloak';
create user if not exists 'keycloak'@'%' identified by 'keycloak';
grant all on keycloak.* to 'keycloak'@'localhost';
grant all on keycloak.* to 'keycloak'@'%';

-- +migrate Down
revoke all on keycloak.* from 'keycloak'@'%';
revoke all on keycloak.* from 'keycloak'@'localhost';
drop user if exists 'keycloak'@'%';
drop user if exists 'keycloak'@'localhost';
drop schema if exists keycloak;

