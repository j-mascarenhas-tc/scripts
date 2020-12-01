#!/bin/bash
####################################
#
# Backup to NFS mount script.
#
####################################

# What to backup. 
backup_files="/mnt/pool-1/dados"

# Where to backup to.
dest="/tmp/backup"

# Create archive filename.
#day=$(date +%A)
day=$(date +%d-%m-%Y.%H.%M)
hostname=$(hostname -s)
archive_file="$hostname-$day.tgz"
retencao="10"


# Print start status message.
echo "Backing up $backup_files to $dest/$archive_file"
date
echo

# Backup the files using tar.
tar czf $dest/$archive_file $backup_files

# Print end status message.
echo
echo "Backup finished"
date

# Long listing of files in $dest to check file sizes.
ls -lh $dest
# 
# 
# Delete old Files
find ${dest} -type f -mtime +${retencao} -exec rm -f '{}' \;
