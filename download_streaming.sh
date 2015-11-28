#!/bin/bash

# Creation date :  november 2015
# This script requires that the following programs be installed
# on your computer:
# - xclip : sudo apt-get install xclip
# - yad (yet another dialog) : http://sourceforge.net/projects/yad-dialog/
# - youtube-dl : sudo apt-get install youtube-dl
# sudo add-apt-repository ppa:nilarimogard/webupd8
# sudo apt-get update
# sudo apt-get upgrade
# sudo apt-get install youtube-dl
#
# To run this script on keys pressed, you can use 'xbindkeys'

# Directory in which will be downloaded videos to download or watch in streaming
DIR_VID=$HOME/Vidéos/From_Web

# Directory in which will be downloaded videos to watch later
DIR_VID_LATER=$HOME/Vidéos/From_Web/To_Watch_Later

# Directory in which will be downloade musics
DIR_MUSIC=$HOME/Téléchargements/Musique

# File in which will be stored the videos watched and downloaded
LOG_FILE=$DIR_VID/history.log

FILENAME_FILE=/tmp/dl_stream_filename
PREFERENCES_FILE=/tmp/dl_stream_preferences

AUDIO_QUALITY=192k
AUDIO_FORMAT=mp3


YTDL="youtube-dl -c"
#--prefer-ffmpeg"
# -c, --continue     force resume of partially downloaded files.
#                    By default, youtube-dl will resume downloads if possible.
# --no-part          do not use .part files
# --prefer-ffmpeg    Prefer ffmpeg over avconv for running the postprocessors

# -s, --simulate     do not download the video and do not write anything to disk
# -t, --title        use title in file name (default)
# -g, --get-url      simulate, quite but print URL
# --get-filename     simulate, quiet but print output filename

get_url() {
  echo DEFAULT_URL : $DEFAULT_URL
  #Displays the dialog and its parameter values in 'FORM'
  FORM=`yad --width=700 --title="Youtube-dl" --form --field="URL :"\
    --field="streaming":CHK --field="download":CHK --field="watch later":CHK\
    --field="music only":CHK  "$DEFAULT_URL" "$STREAMING" "$DOWNLOAD"\
    "$WATCH_LATER" "$MUSIC"`
  #echo $FORM
  MEDIA_URL=`echo $FORM | cut -d '|' -f 1`
  STREAMING=`echo $FORM | cut -d '|' -f 2`
  DOWNLOAD=`echo $FORM | cut -d '|' -f 3`
  WATCH_LATER=`echo $FORM | cut -d '|' -f 4`
  MUSIC=`echo $FORM | cut -d '|' -f 5`
  echo MEDIA_URL = $MEDIA_URL
  echo STREAMING = $STREAMING
  echo DOWNLOAD = $DOWNLOAD
  echo WATCH_LATER = $WATCH_LATER
  echo MUSIC = $MUSIC
}

add_to_log() {
  rm -f $FILENAME_FILE
  if [ ! -e $LOG_FILE ]; then
    touch $LOG_FILE
  fi
  (FILENAME=$($YTDL --get-filename $MEDIA_URL) &&\
  echo $FILENAME>$FILENAME_FILE && sed -i "1i $(date) : $FILENAME" $LOG_FILE)&
}

get_preferences() {
  if [ -e $PREFERENCES_FILE ]; then
    # read preferences from the file $PREFERENCES_FILE
    STREAMING=$(sed '1q;d' $PREFERENCES_FILE)
    DOWNLOAD=$(sed '2q;d' $PREFERENCES_FILE)
    WATCH_LATER=$(sed '3q;d' $PREFERENCES_FILE)
    MUSIC=$(sed '4q;d' $PREFERENCES_FILE)
    #echo STREAMING : $STREAMING
    #echo DOWNLOAD : $DOWNLOAD
    #echo WATCH_LATER : $WATCH_LATER
    #echo MUSIC : $MUSIC
  else
    # set default preferences
    STREAMING="TRUE"
    DOWNLOAD="FALSE"
    WATCH_LATER="FALSE"
    MUSIC="FALSE"
  fi
}

set_player() {
  PLAYER="vlc"
  PLAYER_OPTIONS="--no-video-title-show --input-title-format "
  TITLE="$FILENAME"
  echo FILENAME : $FILENAME
  echo PLAYER : $PLAYER $PLAYER_OPTIONS
}

set_preferences() {
  echo "$STREAMING" > $PREFERENCES_FILE
  echo "$DOWNLOAD" >> $PREFERENCES_FILE
  echo "$WATCH_LATER" >> $PREFERENCES_FILE
  echo "$MUSIC" >> $PREFERENCES_FILE
}

wait_for_filename() {
  while [ ! -e "$FILENAME_FILE" ]
  do
    sleep 0.1
  done
  FILENAME="$(cat "$FILENAME_FILE")"
  rm -f $FILENAME_FILE
  echo filename ready !
}

wait_for_file() {
  if [ $WATCH_LATER = "TRUE" ]; then
    while [ ! -e "$DIR_VID_LATER/$FILENAME" ]
    do
      sleep 0.1
    done
  else
    while [ ! -e "$DIR_VID/$FILENAME" ]
    do
      sleep 0.1
    done
  fi
  echo file ready !
}

wait_all() {
  wait_for_filename
  wait_for_file
}


##########################
# BEGINING OF THE SCRIPT #
##########################


# DEFAULT_URL verification
# Selection content (it is supposed to contain the url of the video or music)
SELECTION=$(xclip -o 2> /dev/null)
CLIPBOARD=$(xclip -o -selection clipboard 2> /dev/null)
DEFAULT_URL=$SELECTION
if [ -z $DEFAULT_URL ]; then
  #echo selection vide
  if [ -z $CLIPBOARD ]; then
  #echo clipboard vide
    #if clipboard is empty and if nothing has been selected a default url is set
    DEFAULT_URL="https://www.youtube.com/watch?v="
  else
    # if nothing has been selected $DEFAULT_URL takes the value of the clipboard
  #echo non vide : clipboard : $CLIPBOARD
    SELECTION=$CLIPBOARD
    DEFAULT_URL=$CLIPBOARD
  fi
else
  #echo selection non vide
  #if something has been selected, the content goes into the clipboard
  #so that the same content be displayed in the URL field if the script
  #is launched again
  echo "$DEFAULT_URL"|xclip -i -selection clipboard
fi

#echo "$SELECTION"|xclip -i -selection XA_PRIMARY
#echo "$CLIPBOARD"|xclip -i -selection clipboard

get_preferences
#Get URL and parameters from User Interface
#And Checks if the parameters are valid
while [ true ]
do
  get_url
  if [ -z $FORM ]; then
    #Quit the dialog if cancel is clicked
    exit 0
  fi
  if [ -z $MEDIA_URL ]; then
    yad --form --field="You MUST enter an URL !":LBL --align=center
    continue
  fi
  if [ $MUSIC = "FALSE" ] && [ $WATCH_LATER = "FALSE" ] && \
    [ $DOWNLOAD = "FALSE" ] &&  [ $STREAMING = "FALSE" ]; then
    yad --form --field="You MUST check at least one checkbox !":LBL
    --align=center
    continue
  fi
  break
done
set_preferences

add_to_log

#Processing parameters
if [ $MUSIC = "TRUE" ]; then
  #A music will be downloaded or listened in streaming
  mkdir -p $DIR_MUSIC
  if [ $WATCH_LATER = "TRUE" || $DOWNLOAD = "TRUE" ]; then
    if [ $STREAMING = "TRUE" ]; then
      #Listening to music in streaming and keeping the music file in $DIR_MUSIC
      echo Listening to music in streaming and keeping the music file in\
        $DIR_MUSIC
    fi
  elif [ $STREAMING = "TRUE" ]; then
    #Listening to music in streaming without keeping the music
    echo Listening to music in streaming without keeping the music
    wait_for_filename && set_player && $YTDL -x -g $MEDIA_URL|xargs $PLAYER \
      $PLAYER_OPTIONS "$TITLE"
  else
    #Downloading music in $DIR_MUSIC without listening to it
    echo Downloading music in $DIR_MUSIC without listening to it
    $YTDL -x --audio-format $AUDIO_FORMAT --audio-quality $AUDIO_QUALITY
  fi
else
  #A video will be downloaded or listened in streaming or watched later
  if [ $WATCH_LATER = "TRUE" ]; then
    mkdir -p $DIR_VID_LATER
    if [ $STREAMING = "TRUE" ]; then
      #Watching the video in streaming and keeping the video in $DIR_VID_LATER
      echo Watching the video in streaming and keeping the video in \
        $DIR_VID_LATER
      FILENAME=`$YTDL --get-filename $MEDIA_URL`
      $YTDL -o "$DIR_VID_LATER/%(title)s-%(id)s.%(ext)s" --no-part $MEDIA_URL &\
        wait_all && $PLAYER "$DIR_VID_LATER/$FILENAME"
    else
      #Downloading the video in $DIR_VID_LATER
      echo Downloading the video in $DIR_VID_LATER
      $YTDL -o "$DIR_VID_LATER/%(title)s-%(id)s.%(ext)s" $MEDIA_URL
    fi
  elif [ $DOWNLOAD = "TRUE" ]; then
    mkdir -p $DIR_VID
    if [ $STREAMING = "TRUE" ]; then
      #Watching the video in streaming and keeping the video in $DIR_VID
      echo Watching the video in streaming and keeping the video in $DIR_VID
      FILENAME=`$YTDL --get-filename $MEDIA_URL`
      $YTDL -o "$DIR_VID/%(title)s-%(id)s.%(ext)s" --no-part $MEDIA_URL &\
        wait_all && $PLAYER "$DIR_VID/$FILENAME"
    else
      #Downloading the video in $DIR_VID without watching it
      echo Downloading the video in $DIR_VID without watching it
      $YTDL -o "$DIR_VID/%(title)s-%(id)s.%(ext)s" $MEDIA_URL
    fi
  else
    #Watching the video in streaming and not keeping the video
    echo Watching the video in streaming and not keeping the video
    wait_for_filename && set_player && $YTDL -g $MEDIA_URL|xargs $PLAYER \
      $PLAYER_OPTIONS "$TITLE"
  fi
fi
exit 0
