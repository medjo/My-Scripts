#! /bin/bash

if [ -z $1 ];
then
	FILE="$(date -Is)"
	FILE=${FILE::-5}
	FILE=$(echo $FILE | sed "s/T/_/")
	FILE=$(echo $FILE | sed "s/:/h/")
	FILE=$(echo $FILE | sed "s/:/min/")
	FILE=$(echo $FILE | sed "s/+/s/")
	FILE="$FILE.mp3"
else
	FILE="$1"
fi

#echo file : $FILE

ffmpeg -f alsa -i pulse -c:a libmp3lame -b:a 128k "$FILE"
