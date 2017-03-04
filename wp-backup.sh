#!/bin/bash
set +x
set -e
set -o pipefail

user=$(whoami)
group=$(id -g -n $user)
BACKUPDIR=/home/$user/wordpress/backup
WORDPRESSDIR=/usr/share/wordpress
dbuser=wordpress
dbpass=wordpress
dbname=wordpress

function create_backup
{
    mkdir -p $BACKUPDIR/wp-content

    sudo cp -f $WORDPRESSDIR/wp-config.php $BACKUPDIR/
    sudo cp -fr $WORDPRESSDIR/wp-content/* $BACKUPDIR/wp-content/
    sudo chown -R $user:$group $BACKUPDIR/

    mysqldump -u $dbuser --password=$dbpass $dbname > $BACKUPDIR/wordpress.sql
}


function restore_backup
{
    mysql -u $dbuser --password=$dbpass $dbname < $BACKUPDIR/wordpress.sql
    sudo cp -f $BACKUPDIR/wp-config.php $WORDPRESSDIR/
    sudo cp -rf $BACKUPDIR/wp-content/* $WORDPRESSDIR/wp-content/
    sudo chown -R root:apache $WORDPRESSDIR/wp-content/
    sudo chown root:apache $WORDPRESSDIR/wp-config.php
}

function usage
{
    echo $0 [-b\|--backup] [-r\|--restore]
    exit 1
}

cmd=""
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -b|--backup)
        cmd=backup
        ;;
        -r|--restore)
        cmd=restore
        ;;
        *)
    ;;
    esac
    shift
done

if [ "$cmd" == "backup" ] ; then
    create_backup
elif [ "$cmd" == "restore" ] ; then
    restore_backup
else
    usage
fi

