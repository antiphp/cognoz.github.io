#!/bin/bash
TYPE=$1
NAME=$2
STATE=$3
case $STATE in
        "MASTER") /usr/bin/touch /var/lib/heketi/vip
                  /bin/systemctl start heketi.service
                  /usr/bin/logger "$1 $2 $3 master state"
                  ;;
        "BACKUP") /bin/rm -rf /var/lib/heketi/vip
                  /bin/systemctl stop heketi.service
                  /usr/bin/logger "$1 $2 $3 $4 stopped state"
                  ;;
        "FAULT")  /bin/rm -rf /var/lib/heketi/vip
                  /bin/systemctl stop heketi.service
                  /usr/bin/logger "$1 $2 $3 $4 fault state"
                  exit 0
                  ;;
        *)        /bin/rm -rf /var/lib/heketi/vip
                  /usr/bin/logger "$1 $2 $3 $4 unknown state"
                  exit 1
                  ;;
esac
