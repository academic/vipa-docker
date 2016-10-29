#!/bin/bash

sed 's/password = .*/password = /g' -i /etc/mysql/debian.cnf
if [ ! -f /var/lib/mysql/ibdata1 ]; then
    echo "Installing new database..."
    if [ ! -f /usr/share/mysql/my-default.cnf ] ; then
        cp /etc/mysql/my.cnf /usr/share/mysql/my-default.cnf
    fi
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null 2>&1

    echo "Starting MySQL server..."
    /usr/bin/mysqld_safe >/dev/null 2>&1 &

    # wait for mysql server to start (max 30 seconds)
    timeout=30
    echo -n "Waiting for database server to accept connections"
    while ! /usr/bin/mysqladmin -u root status >/dev/null 2>&1
    do
        timeout=$(($timeout - 1))
        if [ $timeout -eq 0 ]; then
            echo -e "\nCould not connect to database server. Aborting..."
            exit 1
        fi
        echo -n "."
        sleep 1
    done

    ## create a localhost only, debian-sys-maint user
    ## the debian-sys-maint is used while creating users and database
    ## as well as to shut down or starting up the mysql server via mysqladmin
    echo "Creating debian-sys-maint user..."
    mysql -uroot -e "GRANT ALL PRIVILEGES on *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY '' WITH GRANT OPTION;"

    /usr/bin/mysqladmin --defaults-file=/etc/mysql/debian.cnf shutdown
    echo "Init OK"
fi

exec /usr/bin/mysqld_safe