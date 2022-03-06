#! /bin/bash

# This script connects to the bluetooth speaker specified in $MAC_SPEAKER if it is on. If connection
# fails, it reloads the btusb module and try again to connect to the bluetooth speaker. If it fails
# again we quit, if it succeeds it sets the bluetooth speaker as the default audio output, and sets
# the volume to $DEFAULT_VOLUME

# In order to make this script run at login, you can place it, or a symbolic link in /etc/profile.d/
# In order to make this script run at wake up from sleep or hibernation, you can place it, or a
# symbolic link in /lib/systemd/system-sleep/


#MAC_SPEAKER="FC:58:FA:B7:77:B0" # MINISO99 MAC address of the bluetooth speaker
DEFAULT_VOLUME=7000 # speaker volume (0 = Mute, 65536 = 100%)

################################################################################

# Below this line, nothing shoud be modified if you don't know what you're doing
MAC_SPEAKER_=`echo $MAC_SPEAKER|tr : _`
once=true

CURRENT_USER=`who | cut -d ' ' -f 1`
CURRENT_UID=`id -u $CURRENT_USER`

echo "current user : $CURRENT_USER"
echo "current uid : $CURRENT_UID"

echo -e "info $MAC_SPEAKER\nexit"|bluetoothctl|grep "Connected: no" > /dev/null
if [ $? -eq 0 ]
then
    echo "Bluetooth speaker not connected."
    sleep 1

    bluetoothctl << EOF
    connect $MAC_SPEAKER
EOF

    sleep 3

    echo -e "info $MAC_SPEAKER\nexit"|bluetoothctl|grep "Connected: no" > /dev/null
    if [ $? -eq 0 ]
    then
        echo "Bluetooth speaker still not connected. Reloading module btusb"
        rmmod btusb
        sleep 1
        modprobe btusb
        sleep 1

        bluetoothctl << EOF
        connect $MAC_SPEAKER
EOF
        sleep 3
        echo -e "info $MAC_SPEAKER\nexit"|bluetoothctl|grep "Connected: no" > /dev/null
        if [ $? -eq 0 ]
        then
            echo "Failed to connect bluetooth speaker. Exiting..."
            exit -1
        fi
    fi
fi

echo "Bluetooth speaker is connected."
    
sleep 10

# Set Bluetooth speaker as default audio output
XDG_RUNTIME_DIR=/run/user/$CURRENT_UID runuser -u $CURRENT_USER pacmd set-default-sink bluez_sink.$MAC_SPEAKER_.a2dp_sink|grep exist > /dev/null
while [ $? -eq 0 ]
do
    if [[ "$once" == "true" ]];
    then
        echo "Waiting for bluetooth device to be connected"
        once=false
    fi
    sleep 10
    XDG_RUNTIME_DIR=/run/user/$CURRENT_UID runuser -u $CURRENT_USER pacmd set-default-sink bluez_sink.$MAC_SPEAKER_.a2dp_sink|grep exist > /dev/null
done


echo "Setting bluetooth speaker volume."
# Set Bluetooth speaker volume to about 25% (0 = Mute, 65536 = 100%)
XDG_RUNTIME_DIR=/run/user/$CURRENT_UID runuser -u $CURRENT_USER pacmd set-sink-volume bluez_sink.$MAC_SPEAKER_.a2dp_sink $DEFAULT_VOLUME

exit 0
