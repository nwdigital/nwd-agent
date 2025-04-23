#!/bin/bash -e
# Attempt to generate screenshot of device and send device info and screenshot to server
# Created by Mathew Moore - https://nwdigital.cloud

host="$(snapctl get host)"
int="$(snapctl get interval)"
os="$(snapctl get os)"

ubuntu_core_screenshot() {
   echo "Running NWD-AGENT in Ubuntu Core OS mode."
   screenshot=$(snap run ubuntu-frame.screenshot)
   mv $screenshot $SNAP_REAL_HOME/screenshot.png
   snap run nwd-agent.imagick import -window $USER ${SNAP_REAL_HOME}/output.png
   curl -k -F "ip=${local_ip}" -F "interval=${int}" -F "hostname=${HOSTNAME}" -F "file=@/${SNAP_REAL_HOME}/output.png" "$host/wp-json/nwd-ubcore/v1/register" > /dev/null
}

ubuntu_desktop_screenshot() {
   echo "Running NWD-AGENT in Ubuntu Desktop mode."
   curl -k -F "ip=${local_ip}" -F "interval=${int}" -F "hostname=${HOSTNAME}" "$host/wp-json/nwd-ubcore/v1/register" > /dev/null
}

while true; do

   local_ip=$(hostname -I | awk '{print $1}')

   case $os in

      "desktop")
         ubuntu_desktop_screenshot
         ;;

      "core")
         ubuntu_core_screenshot
         ;;

      *)
         ubuntu_core_screenshot
         ;;

   esac

   sleep $int

done