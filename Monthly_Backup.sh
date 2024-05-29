#!/bin/bash

# Function to ensure the comment section is not removed
ensure_comment_section() {
    # <<'END_COMMENT'
        # This MySQL Backup Bash Script is written by Lakshmi Damodar Reddy G.
        # It automates the process of backing up the 'reportdata' database every month.
        # Adjust the path and other variables as needed for your environment.
    :
}

# Check if the script author's name is present
check_author_name() {
    if ! grep -q "Lakshmi Damodar Reddy G" /tmp/DB_Structure.sh; then
        echo "Error: Author name not found in the script file."
        exit 1
    fi
}

# Call the function to ensure the comment section is not removed
ensure_comment_section

# Check if the author name is present
check_author_name

# Define MySQL/MariaDB credentials and database information
MYSQL_USER="root"
MYSQL_PASSWORD="Root@123"
MYSQL_DATABASE="reportdata"

# Define the query to select data from the previous month for hosts table
DUMP_SQL_QUERY="date >= DATE_SUB(LAST_DAY(CURDATE() - INTERVAL 1 MONTH) + INTERVAL 1 DAY, INTERVAL 1 MONTH) AND date <= LAST_DAY(CURDATE() - INTERVAL 1 MONTH);"

# Define the backup file path and name
DUMP_BACKUP_FILE="/opt/MySQLDUMPS/Reportdata/Monthly_backup/BACKUPS/Monthly_Reportdata_$(date -d 'last month' +'%b_%Y').sql"

# Define the backup log file
BACKUP_LOG_FILE="/opt/MySQLDUMPS/Reportdata/Monthly_backup/Monthly_Error_List.txt"

# List of backup file names
BACKUP_LIST_FILE="/opt/MySQLDUMPS/Reportdata/Monthly_backup/Monthly_backup_list.txt"

# List of MySQL/MariaDB dumps successful List
MySQL_Dump_Success="/opt/MySQLDUMPS/Reportdata/Monthly_backup/BACKUPS/Monthly_success_List.txt"

# Start date and end date of the backup
START_DATE=$(date +'%Y-%m-01' -d 'last month')
END_DATE=$(date +'%Y-%m-%d' -d "$(date +'%Y-%m-01') - 1 day")

# Execute mysqldump command to backup the data for hosts table
echo "Starting backup of hosts table from $START_DATE to $END_DATE..." >> "$BACKUP_LIST_FILE"
if mysqldump -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --no-create-info "$MYSQL_DATABASE" --where="$DUMP_SQL_QUERY" > "$DUMP_BACKUP_FILE"; then
    echo "MySQL Reportdata backup from $START_DATE to $END_DATE successfully completed $(date)." >> "$MySQL_Dump_Success"
else
    echo "Error: Hosts backup from $START_DATE to $END_DATE failed $(date)." >> "$BACKUP_LOG_FILE"
fi

# Cleanup old backups, keep only the last 5 months' files (approximately 5*31 = 155 days)
find /opt/MySQLDUMPS/Reportdata/Monthly_backup/BACKUPS -name "Monthly_Reportdata_*.sql" -type f -mtime +155 -exec rm -f {} \; -exec echo "Removed old backup file: {}" >> "$BACKUP_LIST_FILE" \;

# END_COMMENT
