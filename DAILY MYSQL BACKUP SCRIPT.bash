#!/bin/bash

# Define MySQL/MariaDB credentials and database information
MYSQL_USER="root"
MYSQL_PASSWORD="Root@123"
MYSQL_DATABASE="fascia"

# Define the backup directory
BACKUP_DIR="/opt/backups"

# Define the backup log file
BACKUP_LOG_FILE="/opt/backup_file.txt"

# Current date
CURRENT_DATE=$(date +'%Y-%m-%d')

# Define the SQL queries for hosts and services

HOSTS_SQL_QUERY="last_check >= UNIX_TIMESTAMP(DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '%Y-%m-%d 00:00:00')) AND last_check <= UNIX_TIMESTAMP(DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '%Y-%m-%d 23:59:59'))"

SERVICES_SQL_QUERY="last_check >= UNIX_TIMESTAMP(DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '%Y-%m-%d 00:00:00')) AND last_check <= UNIX_TIMESTAMP(DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '%Y-%m-%d 23:59:59'))"

# Execute mysqldump command to backup the data for hosts table

echo "Starting daily backup of hosts table for $CURRENT_DATE..."
if mysqldump -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --no-create-info "$MYSQL_DATABASE" --where="$HOSTS_SQL_QUERY" hosts > "$BACKUP_DIR/hosts_$CURRENT_DATE.sql"; then
    echo "Hosts backup for $CURRENT_DATE successfully completed." >> "$BACKUP_LOG_FILE"
else
    echo "Error: Hosts backup for $CURRENT_DATE failed." >> "$BACKUP_LOG_FILE"
fi

# Execute mysqldump command to backup the data for services table
echo "Starting daily backup of services table for $CURRENT_DATE..."
if mysqldump -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --no-create-info "$MYSQL_DATABASE" --where="$SERVICES_SQL_QUERY" services > "$BACKUP_DIR/services_$CURRENT_DATE.sql"; then
    echo "Services backup for $CURRENT_DATE successfully completed." >> "$BACKUP_LOG_FILE"
else
    echo "Error: Services backup for $CURRENT_DATE failed." >> "$BACKUP_LOG_FILE"
fi
