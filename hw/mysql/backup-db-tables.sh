#!/bin/bash

BAK_DIR=db_backup

if [ ! -d $BAK_DIR ]
then
    mkdir $BAK_DIR
fi

RUN_MYSQL="mysql --batch --skip-column-names -e "

$RUN_MYSQL "STOP REPLICA"

for db in `$RUN_MYSQL "SELECT db.schema_name FROM information_schema.schemata AS db"`
do
    if [ ! -d $db ]
    then
        mkdir ./"$BAK_DIR"/"$db"
    fi

    for tbl in `$RUN_MYSQL "SELECT tbl.table_name FROM information_schema.tables AS tbl WHERE tbl.table_schema = '$db' and tbl.table_type = 'BASE TABLE'"`
    do
        mysqldump \
            --add-drop-table \
            --add-locks \
            --create-options \
	    --disable-keys \
            --extended-insert \
            --single-transaction \
            --quick \
            --set-charset \
            --events \
            --routines \
            --triggers \
            --set-gtid-purged=OFF \
            --databases "$db" \
            --tables "$tbl" \
          | gzip -1 > ./"$BAK_DIR"/"$db"/"$tbl".sql.gz
    done
done

$RUN_MYSQL "START REPLICA"