#!/bin/bash -e
#ip r get 1.1.1.1 | awk '{print $7}'

host="$(snapctl get host)"
int="$(snapctl get interval)"

# Run this command every 60 seconds
while true; do
    local_ip=$(hostname -I | awk '{print $1}')
    #echo $local_ip
    data="ip=${local_ip}&hostname=${HOSTNAME}"
    #echo "${data}"
    curl -s -d "${data}" "$host/wp-json/nwd-ubcore/v1/register"
    sleep $int 
done
