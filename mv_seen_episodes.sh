#! /bin/bash

# This script is called periodically by cron.
# It is used to move all the episodes that I have downloaded and seen to my
# remote raspberry pi

FILETYPES="*.srt *.flv *.mp4 *.avi *.mkv"
REMOTE_HOST="pi-famille"
DEST="$REMOTE_HOST:~/Videos/Series/"
#SRC="$HOME/test/rsync/"
SRC="$HOME/Vidéos/Séries/Vu"
OPT="-vh --ignore-missing-args --progress --remove-source-files"
TRANSFERT_LOG="~/Videos/Series/transfert.log"
TMP_LOG="~/Videos/Series/transfert.tmp.log"
TMP_LOG2="~/Videos/Series/transfert.tmp.log.2"

cd $SRC
# Do the transfert and write output to temporary log
echo -e "\t\t $(date)" | ssh $REMOTE_HOST "cat >> $TMP_LOG"
rsync $OPT $FILETYPES $DEST | ssh $REMOTE_HOST "cat >> $TMP_LOG"
echo -e "\n\t\t-------------------------------------------\n" |
    ssh $REMOTE_HOST "cat >> $TMP_LOG"

# Append temporary log to beginning of log and remove temporary files
ssh $REMOTE_HOST "cat $TMP_LOG $TRANSFERT_LOG > $TMP_LOG2 2>/dev/null;\
    mv $TMP_LOG2 $TRANSFERT_LOG; rm -f $TMP_LOG"
