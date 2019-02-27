#!/bin/bash

VPN=$1


ROWS=$(tput lines)
COLS=$(tput cols)

if [[ -n "$VPN" ]]
then
  CFG_FILE="/etc/openvpn/client/${VPN}.conf"
  if [[ ! -f "$CFG_FILE" ]]
  then
    echo "Error: config file $CFG_FILE non found!"
    exit 3
  fi
else
  CURR_DIR="$(pwd)"
  cd /etc/openvpn/client/

  let i=0
  FILES=()
  while read -r line
  do # process file by file
    let i=$i+1
    FILES+=(${i} "${line%.conf}")
  done < <( ls -1 *.conf )
  cd "$CURR_DIR"

  if [[ "${#FILES[@]}" -eq "2" ]]
  then
    VPN="${FILES[1]}"
  else
    CHOICE=$(dialog --title "VPN selector" --menu "Choose an OpenVPN client configuration file" $(($ROWS -4)) 80 $(($ROWS -8)) "${FILES[@]}" 3>&2 2>&1 1>&3) # show dialog and store output
    clear
    if [[ -z "$CHOICE" ]]
    then
      exit
    fi
    VPN="${FILES[$(( ($CHOICE -1) *2 +1))]}"
  fi
fi

SERVICE="openvpn-client@${VPN}.service"

TITLE="VPN helper"
MENU="Choose one of the following actions:"
OPTIONS=(refresh "Refresh service status (look at the title)"
         start  "Start VPN ${VPN}"
         stop   "Stop  VPN ${VPN}"
         restart "Restart VPN ${VPN}"
         status "Show status details for VPN ${VPN}"
         quit "Done"
        )

while (true)
do
    SRV_STATE=$(systemctl show -p ActiveState --value "$SERVICE")
    SRV_SUBSTATE=$(systemctl show -p SubState --value "$SERVICE")
    BACKTITLE="VPN ${VPN} (current status: $SRV_STATE $SRV_SUBSTATE)"

    CHOICE=$(dialog --backtitle "$BACKTITLE" \
                    --title "$TITLE" \
                    --menu "$MENU" \
                    $(($ROWS -5)) 80 7 \
                    "${OPTIONS[@]}" \
                    3>&2 2>&1 1>&3 >/dev/tty)
    clear

    case "${CHOICE}" in
      refresh)
        ;;
      start | status | stop | restart)
        echo "Executing:  systemctl $CHOICE ${SERVICE}"
        echo
        sudo systemctl ${CHOICE} "${SERVICE}"
        echo
        if [[ $? -eq 0 ]]
        then
          echo "Result:     done, OK"
        else
          echo "Result:     ERROR"
        fi
        echo
        read -n 1 -s -r -p "Press any key to continue..."
        ;;
      quit | "")
        exit
        ;;
      *)
        echo "You are not allowed to do that!"
        ;;
    esac
done
