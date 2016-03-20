#!/bin/sh

if [ -e /dev/mmcblk0 ]; then
  echo The SD card is plugged in.
  if [ -e ~/Téléchargements/*raspbian-*.img  ]; then
    echo 
  else
    echo Download the Raspbian desktop image from\
    https://www.raspberrypi.org/downloads/raspbian/ and put it in\
    $HOME/Téléchargements
  fi
else
  echo No SD card is plugged in.
  echo Installation aborted.
  return 
fi
