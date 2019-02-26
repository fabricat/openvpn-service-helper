#!/bin/bash

VPN=$1


ROWS=$(tput lines)
COLS=$(tput cols)

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

  if [ "${#W[@]}" -eq "2" ]
  then
    VPN="${W[1]}"
  else
    CHOICE=$(dialog --title "VPN selector" --menu "Choose an OpenVPN client configuration file" $(($ROWS -4)) 80 $(($ROWS -8)) "${W[@]}" 3>&2 2>&1 1>&3) # show dialog and store output
    clear
    if [ -z "$CHOICE" ]
    then
      exit
    fi
    VPN="${W[$((($CHOICE -1) *2 +1))]}"
  fi
fi


SERVICE="openvpn-client@${VPN}.service"
SRV_STATE=$(systemctl show -p ActiveState --value "$SERVICE")
SRV_SUBSTATE=$(systemctl show -p SubState --value "$SERVICE")


TITLE="VPN helper"
BACKTITLE="VPN ${VPN} (current status: $SRV_STATE $SRV_SUBSTATE)"
MENU="Choose one of the following actions:"
OPTIONS=(start  "Start VPN ${VPN}"
         stop   "Stop  VPN ${VPN}"
         restart "Restart VPN ${VPN}"
         status "Show status details for VPN ${VPN}"
         quit "Done"
        )

CHOICE=$(dialog --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $(($ROWS -5)) 80 7 \
                "${OPTIONS[@]}" \
                3>&2 2>&1 1>&3 >/dev/tty)
clear

case $CHOICE in
  start | status | stop | restart)
    echo "Executing:  systemctl $CHOICE ${SERVICE}"
    sudo systemctl $CHOICE "${SERVICE}"
    if [ $? -eq 0 ]
    then
      echo "Result:     done, OK"
    else
      echo "Result:     ERROR"
    fi
    ;;
  quit | "")
    exit
    ;;
  *)
    echo "You are not allowed to do that!"
    ;;
esac
