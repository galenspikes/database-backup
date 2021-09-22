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
OUTPUT_DIR=${MONGODB_BACKUP_FILE_PREFIX}_${DATE}
CONNECTION_TYPE=mongodb

mongo --host=${HOST} --username=${APP_USER} --password="${APP_USER_PASSWORD}" --authenticationDatabase=${MONGODB_AUTH_DB} --quiet < ${WORK_DIR}/list_mongo_dbs.js
for db in $(mongo --host=${HOST} --username=${APP_USER} --password="${APP_USER_PASSWORD}" --authenticationDatabase=${MONGODB_AUTH_DB} --quiet < ${WORK_DIR}/modules/list_mongo_dbs.js); do
  DATE=`date +%Y-%m-%d_%Hh%Mm`
  # Download dump file
  time mongodump --host=${HOST} --username=${APP_USER} --password="${APP_USER_PASSWORD}" --authenticationDatabase=${MONGODB_AUTH_DB} --out=${BACKUP_DIR}/${MONGODB_BACKUP_FILE_PREFIX}_${db}_${DATE} --numParallelCollections=${THREADS} --db=${db}
  # Move to AWS S3
  /usr/local/bin/aws s3 mv ${BACKUP_DIR}/${MONGODB_BACKUP_FILE_PREFIX}_${db}_${DATE} ${S3_BUCKET_NAME}/${S3_SUBDIR}/mongodb/${MONGODB_BACKUP_FILE_PREFIX}_${db}_${DATE} --recursive --quiet
  rm -rfv ${BACKUP_DIR}/${MONGODB_BACKUP_FILE_PREFIX}_${db}_${DATE}
done

