#!/bin/bash

#prerequsite
# install and configure the thin backup plugin to run before the setup time of cron for this script

# Set the source and destination directories
SOURCE_DIR="/var/lib/jenkins/backup-script/FULL*/*"
DEST_BUCKET="s3://store4u-jenkins-backup"


# Set the date format for the backup directory
DATE_FORMAT=$(date +'%Y-%m-%d')

# Set the backup directory name
BACKUP_DIR="jenkins-backup-${DATE_FORMAT}"

# Create a temporary backup directory
TMP_DIR="/tmp/${BACKUP_DIR}"
mkdir -p "${TMP_DIR}"

#copy the backup created by thin backup to tmp location
cp -r ${SOURCE_DIR} ${TMP_DIR}

# remove the previous backup from s3 bucket
aws s3 rm "${DEST_BUCKET}" --recursive --include "jenkins-backup-*"

# Sync the backup file to the S3 bucket
aws s3 sync "${TMP_DIR}" "${DEST_BUCKET}/${BACKUP_DIR}"

# Clean up
rm -rf "${TMP_DIR}"
rm -rf /var/lib/jenkins/backup-script/FULL*
