#!/bin/bash -e
# Attempt to generate screenshot of device and send device info and screenshot to server
# Created by Mathew Moore - https://nwdigital.cloud

host="$(snapctl get host)"
int="$(snapctl get interval)"
os="$(snapctl get os)"
orientation="$(snapctl get orientation)"

ubuntu_core_screenshot() {
   echo "Running NWD-AGENT in default OS mode."
   screenshot=$(snap run ubuntu-frame.screenshot)
   echo $screenshot
   mv $screenshot $SNAP_REAL_HOME/screenshot.png

   if [ ${orientation} == "portrait" ]; then
      # only trim the screenshot if the display is in a ver
      /snap/bin/nwd-agent.imagick ${SNAP_REAL_HOME}/screenshot.png -trim +repage -gravity West -chop 650x0 ${SNAP_REAL_HOME}/output.png
   elif [ ${orientation} == "landscape" ]; then
      mv $SNAP_REAL_HOME/screenshot.png $SNAP_REAL_HOME/output.png
   else
      mv $SNAP_REAL_HOME/screenshot.png $SNAP_REAL_HOME/output.png
   fi

   curl -k -F "ip=${local_ip}" \
         -F "interval=${int}" \
         -F "hostname=${HOSTNAME}" \
         -F "file=@/${SNAP_REAL_HOME}/output.png" \
         "$host/wp-json/nwd-ubcore/v1/register" > /dev/null
}

ubuntu_desktop_screenshot() {
  export DISPLAY=:0
  #export DISPLAY=:0.0

  echo "Running NWD-AGENT in Ubuntu Desktop mode."

  #if [ -d "${SNAP_USER_DATA}/Pictures" ]; then
  #   echo "$SNAP_USER_DATA/Pictures exists"
  #else
  #   echo "${SNAP_USER_DATA}/Pictures doesn't exist. Creating folder.."
  #   mkdir $SNAP_USER_DATA/Pictures
  #   echo "done"
  #fi
  #
  #if [ -f "${SNAP_USER_DATA}/Pictures/Screenshot.png" ]; then
  #   rm "${SNAP_USER_DATA}/Pictures/Screenshot.png"
  #fi

  #secret=$(echo $RANDOM | md5sum | head -c 20; echo)

  #var=$(gdbus call  --session \
  #          --dest=org.freedesktop.portal.Desktop \
  #          --object-path=/org/freedesktop/portal/desktop \
  #          --method=org.freedesktop.portal.Screenshot.Screenshot \
  #          string:root "{'handle_token': <'screenshot_${secret}'>, 'modal': <false>, 'interactive': <false>}")
  #echo $var

  #python3 $SNAP/bin/app.py

  if [ ! -d "${SNAP_COMMON}/Screenshots" ]; then
     echo "${SNAP_COMMON}/Screenshots directory does not exist!"
     echo "Creating directory ${SNAP_COMMON}/Screenshots"
     mkdir ${SNAP_COMMON}/Screenshots
     echo "Created directory ${SNAP_COMMON}/Screenshots"
  else
     echo "${SNAP_COMMON}/Screenshots directory exists!"
  fi

  #echo ${SNAP_USER_COMMON}/Screenshots/
  # result=$(snap run nwd-agent.imagick import -window root ${SNAP_REAL_HOME}/screenshot.png)

  if [ -f "${SNAP_COMMON}/Screenshots/Screenshot.png" ]; then
     echo "Sending info with screenshot to ${host}"
     curl -k -F "file=@/${SNAP_COMMON}/Screenshots/Screenshot.png" \
  	  -F "ip=${local_ip}" -F "interval=${int}" \
  	  -F "hostname=${HOSTNAME}" \
  	  "$host/wp-json/nwd-ubcore/v1/register" > /dev/null
  else
     echo "Sending info without screenshot to ${host}"
     curl -k -F "ip=${local_ip}" -F "interval=${int}" \
          -F "hostname=${HOSTNAME}" \
          "$host/wp-json/nwd-ubcore/v1/register" > /dev/null
  fi

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
