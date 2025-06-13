FROM debian:buster

ENV DEBIAN_FRONTEND=noninteractive

# Create mysql user and directories with correct permissions first
RUN groupadd -r mysql && \
    useradd -r -g mysql mysql && \
    mkdir -p /var/lib/mysql /var/run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql /var/run/mysqld && \
    chmod 777 /var/run/mysqld

# Install MariaDB
RUN apt-get update && \
    apt-get install -y mariadb-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy configuration
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/
RUN chown mysql:mysql /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy initialization script
COPY conf/script.sh /script.sh
RUN chmod +x /script.sh && \
    chown mysql:mysql /script.sh

# Set user and volumes
USER mysql
VOLUME /var/lib/mysql

EXPOSE 3306

CMD ["/script.sh"]