#!/bin/bash

# Define MySQL/MariaDB credentials and database information
MYSQL_USER="root"
MYSQL_PASSWORD="Root@123"
MYSQL_DATABASE="fascia"

# Define the query to select data from the previous month for hosts table
HOSTS_SQL_QUERY="SELECT * FROM hosts WHERE last_check >= UNIX_TIMESTAMP(DATE_SUB(LAST_DAY(CURDATE()), INTERVAL 1 MONTH)) AND last_check <= UNIX_TIMESTAMP(LAST_DAY(CURDATE() - INTERVAL 1 DAY));"

# Define the query to select data from the previous month for services table
SERVICES_SQL_QUERY="SELECT * FROM services WHERE last_check >= UNIX_TIMESTAMP(DATE_SUB(LAST_DAY(CURDATE()), INTERVAL 1 MONTH)) AND last_check <= UNIX_TIMESTAMP(LAST_DAY(CURDATE() - INTERVAL 1 DAY));"

# Define the backup file paths
HOSTS_BACKUP_FILE="/opt/hosts_$(date +'%b_%Y').sql"
SERVICES_BACKUP_FILE="/opt/services_$(date +'%b_%Y').sql"

# Define the backup log file
BACKUP_LOG_FILE="/opt/backup_file.txt"

# Start date and end date of the backup
START_DATE=$(date +'%Y-%m-01')
END_DATE=$(date +'%Y-%m-%d' -d "$(date +'%Y-%m-01') +1 month -1 day")

# Execute mysqldump command to backup the data for hosts table
echo "Starting backup of hosts table from $START_DATE to $END_DATE..."
if mysqldump -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --no-create-info "$MYSQL_DATABASE" --where="$HOSTS_SQL_QUERY" hosts > "$HOSTS_BACKUP_FILE"; then
    echo "Hosts backup from $START_DATE to $END_DATE successfully completed." >> "$BACKUP_LOG_FILE"
else
    echo "Error: Hosts backup from $START_DATE to $END_DATE failed." >> "$BACKUP_LOG_FILE"
fi

# Execute mysqldump command to backup the data for services table
echo "Starting backup of services table from $START_DATE to $END_DATE..."
if mysqldump -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --no-create-info "$MYSQL_DATABASE" --where="$SERVICES_SQL_QUERY" services > "$SERVICES_BACKUP_FILE"; then
    echo "Services backup from $START_DATE to $END_DATE successfully completed." >> "$BACKUP_LOG_FILE"
else
    echo "Error: Services backup from $START_DATE to $END_DATE failed." >> "$BACKUP_LOG_FILE"
fi
