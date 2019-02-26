#!/bin/bash

VPN=$1
if [ -n "$VPN" ]
then
  CFG_FILE="/etc/openvpn/client/${VPN}.conf"
  if [ ! -f "$CFG_FILE" ]
  then
    echo "Error: config file $CFG_FILE non found!"
    exit 3
  fi
else
  CURR_DIR="$(pwd)"
  cd /etc/openvpn/client/

  let i=0
  W=() # define working array
  while read -r line; do # process file by file
    let i=$i+1
    W+=($i "${line%.conf}")
  done < <( ls -1 *.conf )
  cd "$CURR_DIR"

  CHOICE=$(dialog --title "VPN selector" --menu "Choose an OpenVPN client configuration file" 24 80 17 "${W[@]}" 3>&2 2>&1 1>&3) # show dialog and store output
  clear

  if [ -z "$CHOICE" ]
  then
    exit
  fi
  VPN="${W[$((($CHOICE -1) *2 +1))]%}"
fi


SERVICE="openvpn-client@${VPN}.service"
SRV_STATE=$(systemctl show -p ActiveState --value "$SERVICE")
SRV_SUBSTATE=$(systemctl show -p SubState --value "$SERVICE")


HEIGHT=15
WIDTH=80
CHOICE_HEIGHT=6
TITLE="VPN helper"
BACKTITLE="VPN ${VPN} (current status: $SRV_STATE $SRV_SUBSTATE)"
MENU="Choose one of the following options:"

OPTIONS=(start "Start VPN ${VPN}"
         status "Show VPN ${VPN} status details"
         stop "Stop VPN ${VPN}"
         restart "Restart VPN ${VPN}"
         quit "Done"
        )

CHOICE=$(dialog --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                3>&2 2>&1 1>&3)
clear

case $CHOICE in
  start | status | stop | restart)
    sudo systemctl $CHOICE "${SERVICE}"
    ;;
  quit | "")
    exit
    ;;
  *)
    echo "You are not allowed to do that!"
    ;;
esac
