FROM bitnami/minideb

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get update && \
    apt-get install -y \
        apache2 \
        perl \
        libcgi-pm-perl \
        mariadb-server \
        mariadb-client \
        libdbd-mysql-perl \
        libjson-perl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN a2enmod cgid && \
    mkdir -p /usr/lib/cgi-bin /var/www/html /var/lib/mysql /run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql /run/mysqld && \
    chmod -R 755 /usr/lib/cgi-bin /var/www/html

RUN mariadb-install-db --user=mysql --datadir=/var/lib/mysql

COPY ./cgi-bin/ /usr/lib/cgi-bin/
COPY ./html/ /var/www/html/
COPY ./init_db.sql /docker-entrypoint-initdb.d/

RUN chmod 644 /docker-entrypoint-initdb.d/init_db.sql && \
    chown mysql:mysql /docker-entrypoint-initdb.d/init_db.sql && \
    chmod +x /usr/lib/cgi-bin/*.pl

CMD ["/bin/bash", "-c", "mysqld --datadir=/var/lib/mysql --user=mysql --skip-grant-tables & sleep 5 && mysql < /docker-entrypoint-initdb.d/init_db.sql && apachectl -D FOREGROUND"]

EXPOSE 80
