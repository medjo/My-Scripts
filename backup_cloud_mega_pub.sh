#!/bin/sh

# This script has been inspired by this article :
# http://www.matteomattei.com/backup-your-server-on-mega-co-nz-using-megatools/


#******************************************************************************#
#                       DESCRIPTION                                            #
#******************************************************************************#


# This script will do the following :
# - create an archive containing all the folders indicated ($FOLDER1, ...)
# - name the archive "backup_2015-11-27.tar" if the script has been launched on
# november, 27th 2015.
# - this archive will be placed locally in $LOCAL_BACKUP and in your mega
# account in $REMOTE_PATH
# both the local and remote folder will eventually store a backup from the 9
# past days and one of the current day (so 10 in total)
# - if this script is run more than once a day, it will update the backup of the
# current day (remove the old ones -locally and remotely- and generate a new
# one).

# In order to have this script run every hour edit your crontab file by typing :
# $ sudo crontab -e
# Then add the following line :
# 0 * * * * path/to/this/script.sh

#******************************************************************************#


BASE_DIR="$HOME/Documents"
LOCAL_BACKUP="$HOME/Documents/Backup/Documents"
REMOTE_PATH="/Root/Backup"
CONFIG_FILE="/root/.megarc"
BACKUP_NUMBER=0

#The folowing folders will be stored to the mega account
FOLDER1="$BASE_DIR/Comptes"
FOLDER2="$BASE_DIR/Documents_Administratifs"
FOLDER3="$BASE_DIR/Mes_Programmes"
FOLDER4="$BASE_DIR/Scripts"
MEGA_PATH="/usr/local/bin"
DATE="TODAY"

create_filename(){
  #Création du nom du fichier de sauvegarde :
  DATE=$(date -Idate)
  BACKUP_FILENAME=$(echo "backup_$DATE.tar")
  ARCHIVE="$LOCAL_BACKUP/$BACKUP_FILENAME"
  echo "archive to be created : $BACKUP_FILENAME"
}

create_archive(){
  #creation of the archive
  echo "archive creation..."
  tar cf "$ARCHIVE" "$FOLDER1" "$FOLDER2" "$FOLDER3" "$FOLDER4"
}

upload_backup(){
  #upload the backup archive to remote mega account
  echo "backup uploading..."
  $MEGA_PATH/megaput --config "$CONFIG_FILE" --path "$REMOTE_PATH" "$ARCHIVE"||\
    exit -1
}

date
create_filename
BACKUP_NUMBER=$(ls -1 "$LOCAL_BACKUP"|wc -l) 
if [ -e "$ARCHIVE" ]; then
  #same day : remove the newest backup (from 1 hour ago)
  #it is going to be replaced with a new one
  echo "local deletion..."
  rm "$ARCHIVE"
  echo "remote deletion..."
  $MEGA_PATH/megarm --config "$CONFIG_FILE" "$REMOTE_PATH"/"$BACKUP_FILENAME"
elif [ $BACKUP_NUMBER -ge 10 ]; then
  #new day : remove the backup from 9 days ago (the oldest among the 10)
  OLDEST_BACKUP=$(ls -1|awk 'NR==1{print $1}')
  echo "local deletion..."
  rm "$OLDEST_BACKUP"
  echo "remote deletion..."
  $MEGA_PATH/megarm --config  "$CONFIG_FILE" "$REMOTE_PATH"/"$OLDEST_BACKUP"
fi
create_archive
upload_backup
