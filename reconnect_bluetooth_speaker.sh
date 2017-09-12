#! /bin/bash
SPEAKER="FC:58:FA:B7:77:B0"

bluetoothctl << EOF
disconnect $SPEAKER
EOF

sleep 3

bluetoothctl << EOF
connect $SPEAKER
EOF
