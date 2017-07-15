#!/bin/bash

HOST=afu.cd75gda2paem.ap-northeast-1.rds.amazonaws.com
USER=$1
PASSWORD=$2
DATABASE=afu_production
DB_FILE=$3
EXCLUDED_TABLES=(
log_closes
log_pushes
)


IGNORED_TABLES_STRING=''
for TABLE in "${EXCLUDED_TABLES[@]}"
do :
  IGNORED_TABLES_STRING+=" --ignore-table=${DATABASE}.${TABLE}"
done

mysqldump --host=${HOST} --user=${USER} --password=${PASSWORD} --single-transaction --no-data ${DATABASE} > ${DB_FILE}

mysqldump --host=${HOST} --user=${USER} --password=${PASSWORD} ${DATABASE} ${IGNORED_TABLES_STRING} > ${DB_FILE}
