FROM mysql

ADD migrate.sh /migrate.sh
RUN mkdir /docker-entrypoint-migrations.d
VOLUME /docker-entrypoint-migrations.d

CMD /migrate.sh