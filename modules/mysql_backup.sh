#!/bin/bash

while [[ "$1" == --* ]]; do
  case "$1" in
  --schema-name)
    shift
    SCHEMA_NAME="$1"
    ;;
  --working-directory)
    shift
    WORK_DIR="$1"
    ;;
  --config-file)
    shift
    BACKUP_CONFIG_FILE="$1"
    ;;
  -h|--help)
    usage
    exit 0
    ;;
  --)
    shift
    break
    ;;
  esac
  shift
done
shift $(( OPTIND - 1 ))

echo ${SCHEMA_NAME}
echo ${WORK_DIR}
echo ${BACKUP_CONFIG_FILE}
source ${BACKUP_CONFIG_FILE}

#######################################################################################################################################################################
# MAIN
#######################################################################################################################################################################
DATE=`date +%Y-%m-%d_%Hh%Mm`
OUTPUT_DIR=${MYSQL_BACKUP_FILE_PREFIX}_${SCHEMA_NAME}_${DATE}
CONNECTION_TYPE=mysql

/usr/bin/time /usr/bin/mydumper --database ${SCHEMA_NAME} --outputdir ${BACKUP_DIR}/${OUTPUT_DIR} --no-locks --use-savepoints --host ${HOST} --user ${APP_USER} --password "${APP_USER_PASSWORD}" --threads ${THREADS} -v 3 --routines --triggers --events --compress

/usr/bin/tar -czvf ${BACKUP_DIR}/${OUTPUT_DIR}.tar.gz ${BACKUP_DIR}/${OUTPUT_DIR}/
/usr/local/bin/aws s3 mv ${BACKUP_DIR}/${OUTPUT_DIR}.tar.gz ${S3_BUCKET_NAME}/${S3_SUBDIR}/mysql/${OUTPUT_DIR}.tar.gz --quiet
/usr/bin/rm -rfv ${BACKUP_DIR}/${OUTPUT_DIR}/
