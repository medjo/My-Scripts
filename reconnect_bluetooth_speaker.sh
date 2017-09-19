#! /bin/bash
SPEAKER="FC:58:FA:B7:77:B0"
once=true

bluetoothctl << EOF
disconnect $SPEAKER
EOF

sleep 3

bluetoothctl << EOF
connect $SPEAKER
EOF

sleep 4
# Set Bluetooth speaker as default audio output
pacmd set-default-sink bluez_sink.FC_58_FA_B7_77_B0|grep exist > /dev/null
while [ $? -eq 0 ]
do
    if [[ "$once" == "true" ]];
    then
        echo "Waiting for bluetooth device to be connected"
        once=false
    fi
    pacmd set-default-sink bluez_sink.FC_58_FA_B7_77_B0|grep exist > /dev/null
done

# Set Bluetooth speaker volume to about 25% (0 = Mute, 65536 = 100%)
pacmd set-sink-volume bluez_sink.FC_58_FA_B7_77_B0 15000
