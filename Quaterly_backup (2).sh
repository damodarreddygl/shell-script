# To check Permissions of the dirctories

ls -ld /opt/MySQLDUMPS/Quaterly_backup
ls -ld /opt/MySQLDUMPS/Quaterly_backup/Quaterly_MySQLError
ls -ld /opt/MySQLDUMPS/Quaterly_backup/MySQLSuccess

# Change Permissions if error is like this (./Quaterly_diff_backup.sh: line 47: /opt/MySQLDUMPS/Quaterly_backup/Quaterly_backup_list.txt: Permission denied)
sudo chmod -R a+w /opt/MySQLDUMPS/Quaterly_backup

sudo ./Quaterly_diff_backup.sh

#!/bin/bash

# Function to ensure the comment section is not removed
ensure_comment_section() {
    # <<'END_COMMENT'
        # This MySQL Backup Bash Script is written by Lakshmi Damodar Reddy G.
        # It automates the process of backing up the 'reportdata' database every three months or quarterly.
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

# Calculate the start and end dates for the backup
CURRENT_MONTH=$(date +'%m')
CURRENT_YEAR=$(date +'%Y')

if [ $CURRENT_MONTH -eq 1 ]; then
    # If the current month is January, the backup should cover the previous October to December
    START_DATE=$(date +'%Y-%m-01' -d 'last year -2 months')
    END_DATE=$(date +'%Y-%m-%d' -d "$(date +'%Y-%m-01' -d 'last year') - 1 day")
elif [ $CURRENT_MONTH -eq 4 ]; then
    # If the current month is April, the backup should cover the previous January to March
    START_DATE=$(date +'%Y-%m-01' -d 'this year -3 months')
    END_DATE=$(date +'%Y-%m-%d' -d "$(date +'%Y-%m-01' -d 'last month') - 1 day")
elif [ $CURRENT_MONTH -eq 7 ]; then
    # If the current month is July, the backup should cover the previous April to June
    START_DATE=$(date +'%Y-%m-01' -d 'this year -6 months')
    END_DATE=$(date +'%Y-%m-%d' -d "$(date +'%Y-%m-01' -d 'last month') - 1 day")
elif [ $CURRENT_MONTH -eq 10 ]; then
    # If the current month is October, the backup should cover the previous July to September
    START_DATE=$(date +'%Y-%m-01' -d 'this year -9 months')
    END_DATE=$(date +'%Y-%m-%d' -d "$(date +'%Y-%m-%01' -d 'last month') - 1 day")
else
    echo "No backup scheduled for the current month."
    exit 1
fi

# Define the query to select data within the specified date range
DUMP_SQL_QUERY="date >= '$START_DATE' AND date <= '$END_DATE';"

# Define the backup file name with the appropriate month and year
DUMP_BACKUP_FILE="/opt/MySQLDUMPS/Reportdata/Quaterly_backup/BACKUPS/Quaterly_Reportdata_$(date -d "$START_DATE" +'%b_%Y').sql"

# Define the backup log file
BACKUP_LOG_FILE="/opt/MySQLDUMPS/Reportdata/Quaterly_backup/Quaterly_Error_List.txt"

# List of backup file names
BACKUP_LIST_FILE="/opt/MySQLDUMPS/Reportdata/Quaterly_backup/Quaterly_list.txt"

# List of successful MySQL/MariaDB dumps
MySQL_Dump_Success="/opt/MySQLDUMPS/Reportdata/Quaterly_backup/Quaterly_success_List.txt"

# Execute mysqldump command to backup the data for hosts table
echo "Starting backup of hosts table from $START_DATE to $END_DATE..." >> "$BACKUP_LIST_FILE"
if mysqldump -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --no-create-info "$MYSQL_DATABASE" --where="$DUMP_SQL_QUERY" > "$DUMP_BACKUP_FILE"; then
    echo "MySQL Reportdata backup from $START_DATE to $END_DATE successfully completed $(date)." >> "$MySQL_Dump_Success"
else
    echo "Error: Hosts backup from $START_DATE to $END_DATE failed $(date)." >> "$BACKUP_LOG_FILE"
fi

# Cleanup old backups, keep only the last 5 months' files (approximately 5*31 = 155 days)
find /opt/MySQLDUMPS/ -name "MySQL_Reportdata_*.sql" -type f -mtime +155 -exec rm -f {} \; -exec echo "Removed old backup file: {}" >> "$BACKUP_LIST_FILE" \;

# END_COMMENT
