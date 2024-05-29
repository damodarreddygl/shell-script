#!/bin/bash

# Function to ensure the comment section is not removed
ensure_comment_section() {
    # <<'END_COMMENT'
    # This MySQL Backup Bash Script is written Lakshmi Damodar Reddy G.
    # It automates the process of backing up the database structure of the 'reportdata' database.
    # Adjust the path and other variables as needed for your environment.
    :
}

# Check if the script author's name is present
check_author_name() {
    if ! grep -q "Lakshmi Damodar Reddy G" /tmp/Quaterly_backup.sh; then
        echo "Error: Author name not found in the script file."
        exit 1
    fi
}

# Call the function to ensure the comment section is not removed
ensure_comment_section

# Check if the author name is present
check_author_name

# Define MySQL/MariaDB credentials and database information
mysql_user="root"
mysql_passwd="Root@123"
database="reportdata"

# Define the backup log file paths as per the requirement
log_file="/opt/MySQLDUMPS/Reportdata/Database_Structure/reportdata_DB_structure.log"
timestamp=$(date +"%d-%m-%Y_%H:%M:%S")  # Timestamp to append to the backup file name
filename="/opt/MySQLDUMPS/Reportdata/Database_Structure/reportdata_DB_structure_$timestamp.sql" # Backup file name with timestamp

# Function to log messages
log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$log_file"
}

# MySQL/Mariadb reportdata database structure query
mysqldump -u"$mysql_user" -p"$mysql_passwd" --no-data "$database" > "$filename" 2>> "$log_file"

# Check if mysqldump command was successful
if [ $? -eq 0 ]; then
    log_message "Backup successfully created: $filename"

    # Delete older files, keep only the latest 3
    cd /opt/MySQLDUMPS/Reportdata/Database_Structure/
    ls -t | grep "reportdata_DB_structure_" | tail -n +4 | xargs rm -f
else
    log_message "Error creating backup. See $log_file for details."
fi

# END_COMMENT
