#!/bin/bash -e

host="$(snapctl get host)"
int="$(snapctl get interval)"

while true; do
    local_ip=$(hostname -I | awk '{print $1}')
    data="ip=${local_ip}&hostname=${HOSTNAME}"
    curl -s -d "${data}" "$host/wp-json/nwd-ubcore/v1/register" > /dev/null
    sleep $int
done


