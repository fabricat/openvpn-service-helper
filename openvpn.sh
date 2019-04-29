#!/bin/bash

### ...sorry for the missing usage hints

### Activate debug
if [[ "$1" == "-d" ]]
then
    set -x
    DEBUG="true"
    shift
fi

### Accept explicit VPN config file
VPN=$1

### End of params



readonly CFG_PATH='/etc/openvpn/'
readonly CFG_EXT='.conf'
ROWS=$(tput lines 2>/dev/null || echo 25)

function clearScreen()
{
    if [[ "${DEBUG}" == "true" ]]
    then
        clear
    fi
}


##############################################
### Phase 1: choose VPN configuration file ###
##############################################
VPN="${VPN#"${CFG_PATH}"}"
VPN="${VPN%"${CFG_EXT}"}"

if [[ -n "$VPN" ]]
then
  CFG_FILE="${CFG_PATH}${VPN}${CFG_EXT}"
  if [[ ! -f "$CFG_FILE" ]]
  then
    echo "Error: config file $CFG_FILE non found!"
    exit 3
  fi
else
  i=0
  FILES=()
  while read -r line
  do # process file by file
    let i=$i+1

    line="${line#"${CFG_PATH}"}"
    FILES+=(${i} "${line%"${CFG_EXT}"}")
  done < <( find "${CFG_PATH}" -path "${CFG_PATH}server" -prune -o -type f -name "*${CFG_EXT}" -print )

  if [[ "${#FILES[@]}" -eq "0" ]]
  then
    echo "Error: no config file found! (no match: ${CFG_PATH} ... *${CFG_EXT})"
    exit 3
  fi
  if [[ "${#FILES[@]}" -eq "2" ]]
  then
    VPN="${FILES[1]}"
  else
    CHOICE=$(dialog --title "VPN selector" --menu "Choose an OpenVPN client configuration file" $(($ROWS -4)) 80 $(($ROWS -8)) "${FILES[@]}" 3>&2 2>&1 1>&3) # show dialog and store output
    clearScreen
    if [[ -z "$CHOICE" ]]
    then
      exit
    fi
    VPN="${FILES[$(( ($CHOICE -1) *2 +1))]}"
  fi
fi

if [[ "${VPN}" == client/* ]]
then
    SERVICE="openvpn-client@${VPN#client/}.service"
else
    SERVICE="openvpn@${VPN}.service"
fi


###############################################
### Phase 2: let's ride the OpenVPN service ###
###############################################
TITLE="OpenVPN service helper"
MENU="Choose one of the following actions:"
OPTIONS=(refresh "Refresh service status (look at the title)"
         start   "Start   VPN ${VPN}"
         stop    "Stop    VPN ${VPN}"
         restart "Restart VPN ${VPN}"
         status  "Show service status details"
         quit "Done"
        )

while (true)
do
    SRV_STATE=$(systemctl show -p ActiveState "$SERVICE")
    SRV_SUBSTATE=$(systemctl show -p SubState "$SERVICE")
    BACKTITLE="Service ${SERVICE} ($SRV_STATE $SRV_SUBSTATE)"

    CHOICE=$(dialog --backtitle "$BACKTITLE" \
                    --title "$TITLE" \
                    --menu "$MENU" \
                    $(($ROWS -5)) 80 7 \
                    "${OPTIONS[@]}" \
                    3>&2 2>&1 1>&3 >/dev/tty)
    clearScreen

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
