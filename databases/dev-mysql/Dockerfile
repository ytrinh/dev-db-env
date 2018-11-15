FROM mysql:5.7

LABEL authors="Yung Trinh"

RUN mkdir /scripts

ENV MYSQL_ALLOW_EMPTY_PASSWORD 1
ENV MYSQL_USER dev
ENV MYSQL_PASSWORD dev
ENV MYSQL_DATABASE dev

COPY ./cli.sh /scripts/cli.sh
COPY ./backup.sh /scripts/backup.sh
COPY ./restore.sh /scripts/restore.sh
RUN chmod +x /scripts/*.sh 

EXPOSE 3306

CMD ["mysqld", "--character-set-server=utf8mb4", "--collation-server=utf8mb4_unicode_ci"]
