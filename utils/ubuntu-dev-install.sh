#!/bin/bash

echo "Change this script"
DB_USER=mydbuser
DB_NAME=mydbname
SITE_NAME=mysite

function install_packages() {
    apt-get install apache2
    apt-get install php5
    apt-get install php5-gd
    apt-get install postgresql-8.4
    apt-get install php5-pgsql
    apt-get install postgresql-client-8.4
}
# database and user
function create_database() {
    echo "Enter the password for $DB_USER on database $DB_NAME: "
    sudo -u postgres createuser --pwprompt --encrypted --no-createrole --no-createdb $DB_USER
    sudo -u postgres createdb --encoding=UTF8 --owner=$DB_USER $DB_NAME
}

#drupal itself
# sitename = $SITE_NAME
function install_drupal7() {
    cd 
    wget http://ftp.drupal.org/files/projects/drupal-7.2.tar.gz
    tar -zxvf drupal-7.2.tar.gz
    mkdir -p /var/www/$SITE_NAME
    mv drupal-7.2/* drupal-7.2/.htaccess /var/www/$SITE_NAME
    cd /var/www/$SITE_NAME
    chmod a+w sites/default
    cp sites/default/default.settings.php sites/default/settings.php
    chmod a+w sites/default/settings.php
    rm /var/www/index.html
    a2enmod rewrite
    /etc/init.d/apache2 restart
}

function delete_database() {
    sudo -u postgres dropdb $DB_NAME
    sudo -u postgres dropuser $DB_USER
}

# deletes drupal from webserver
function delete_drupal7() {
    rm -rf /var/www/$SITE_NAME/*
}


# install packages etc.
function main_install() {
    install_packages
    create_database
    install_drupal7
}

# delete
function main_delete() {
    delete_drupal7
    delete_database
}


function main_post_install() {
#cleanup
#post install
    cd /var/www/$SITE_NAME/
    chmod go-w sites/default
    chmod go-w sites/default/settings.php
    chmod go-w sites/default/settings.php
    chmod go-w sites/default

}


# Program flow
function main() {
    echo "Install or Delete or PostInstall drupal site $SITE_NAME? [I or D or P]"
    read ANSWER
    if [ "x$ANSWER" = "xI" ]; then
	echo "Install"
	main_install
    elif [ "x$ANSWER" = "xD" ]; then
	echo "Delete"
	main_delete
    elif [ "x$ANSWER" = "xP" ]; then
	echo "Post install."
	main_post_install
    else
	echo "Hmm, cant do that"
    fi


}

main

echo "Dont forget to set 5433 as port when installing the site from web."
