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

source ${BACKUP_CONFIG_FILE}

#######################################################################################################################################################################
# MAIN
#######################################################################################################################################################################
DATE=`date +%Y-%m-%d_%Hh%Mm`
OUTPUT_DIR=${BACKUP_DIR}/${POSTGRESQL_BACKUP_FILE_PREFIX}_${SCHEMA_NAME}_${DATE}
CONNECTION_TYPE=postgresql

time pg_dump --verbose -h ${HOST} -U ${APP_USER} -Z 3 -j ${THREADS} -F d -f ${OUTPUT_DIR} -d ${SCHEMA_NAME}
cd ${BACKUP_DIR}
tar -cvf ${POSTGRESQL_BACKUP_FILE_PREFIX}_${SCHEMA_NAME}_${DATE}.tar ${POSTGRESQL_BACKUP_FILE_PREFIX}_${SCHEMA_NAME}_${DATE}/*
/usr/local/bin/aws s3 mv ${POSTGRESQL_BACKUP_FILE_PREFIX}_${SCHEMA_NAME}_${DATE}.tar ${S3_BUCKET_NAME}/${S3_SUBDIR}/postgresql/${POSTGRESQL_BACKUP_FILE_PREFIX}_${SCHEMA_NAME}_${DATE}.tar --quiet
rm -rfv ${OUTPUT_DIR}
echo Complete!
