#!/bin/sh
DEVICE_NAME=/dev/mmcblk0
RASBIAN_IMG=~/Téléchargements/2016-02-09-raspbian-jessie.img
if [ -e $DEVICE_NAME ]; then
  echo The SD card is plugged in.
  if [ -e $RASBIAN_IMG  ]; then
    echo Raspbian desktop image was found.
    PARTITION_X=1
    while [ -e $DEVICE_NAME\p$PARTITION_X ]
    do
      echo
      echo umount $DEVICE_NAME\p$PARTITION_X
      umount $DEVICE_NAME\p$PARTITION_X
      PARTITION_X=$((PARTITION_X + 1))
    done
    echo
    echo authentification is needed to write the image to SD card
    echo this might take a while
    sudo dd bs=4M if=$RASBIAN_IMG of=$DEVICE_NAME
    sync
    echo Done. You may remove the SD card from the card reader.
  else
    echo Download the Raspbian desktop image from\
    https://www.raspberrypi.org/downloads/raspbian/ and indicate its location \
    in the RASBIAN_IMG variable
  fi
else
  echo No SD card is plugged in.
  echo Installation aborted.
  return 
fi
