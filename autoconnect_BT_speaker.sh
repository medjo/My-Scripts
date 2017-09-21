#! /bin/bash

# This script auto detects when the bluetooth speaker specified in $MAC_SPEAKER
# is on. If not, it retries $CHECK_TIME seconds later. If it is on, it connects
# to the speaker and set the volume to $DEFAULT_VOLUME


MAC_SPEAKER="FC:58:FA:B7:77:B0" # MAC address of the bluetooth speaker
DEFAULT_VOLUME=15000 # speaker volume (0 = Mute, 65536 = 100%)
CHECK_TIME=20 # Duration in seconds between two detection of speaker activation

################################################################################

# Below this line, nothing shoud be modified if you don't know what you're doing
MAC_SPEAKER_=`echo $MAC_SPEAKER|tr : _`
once=true


echo -e "info $MAC_SPEAKER\nexit"|bluetoothctl|grep "Connected: no" > /dev/null
while [ $? -eq 0 ]
do
    #echo "Bluetooth speaker not activated. Retry in 20 sec"
    sleep 20
    echo -e "info $MAC_SPEAKER\nexit"|bluetoothctl|grep "Connected: no" > /dev/null
done

#echo "Bluetooth speaker is activated."
    
bluetoothctl << EOF
disconnect $MAC_SPEAKER
EOF

sleep 3

bluetoothctl << EOF
connect $MAC_SPEAKER
EOF

# Set Bluetooth speaker as default audio output
pacmd set-default-sink bluez_sink.$MAC_SPEAKER|grep exist > /dev/null
while [ $? -eq 0 ]
do
    if [[ "$once" == "true" ]];
    then
        echo "Waiting for bluetooth device to be connected"
        once=false
    fi
    sleep 0.2
    pacmd set-default-sink bluez_sink.$MAC_SPEAKER_|grep exist > /dev/null
done

# Set Bluetooth speaker volume to about 25% (0 = Mute, 65536 = 100%)
pacmd set-sink-volume bluez_sink.$MAC_SPEAKER_ $DEFAULT_VOLUME
