#! /bin/bash

# This script is called periodically by cron.
# It is used to move all the episodes that I have downloaded and seen to my
# remote raspberry pi

FILETYPES="*.srt *.flv *.mp4 *.avi *.mkv"
DEST="pi-famille:~/Videos/Series/"
SRC="$HOME/Vidéos/Séries/Vu"
OPT="-vh --ignore-missing-args --progress --remove-source-files"

cd $SRC
rsync $OPT $FILETYPES $DEST
