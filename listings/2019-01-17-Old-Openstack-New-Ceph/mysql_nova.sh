#!/bin/bash
set -x
source openrc.merg
rm -rf instance_uuid
nova list | awk '{print $2}' | grep -v ID >> instance_uuid
USER='nova'
PASS='rMQ7CmIs'
DB='nova'

MONOLD=("'10.220.109.5'" "'10.220.109.8'" "'10.220.109.9'")
MONNEW=("'10.220.109.15'" "'10.220.109.16'" "'10.220.109.17'")
LIKE=("'%10.220.109.5%'" "'%10.220.109.8%'" "'%10.220.109.9%'")

while read uuid; do
  for i in {0..2};
    do
      mysql -h "localhost" -u "$USER" "-p$PASS" "$DB" -Bse "update block_device_mapping SET connection_info = REPLACE(connection_info, ${MONOLD[$i]}, ${MONNEW[$i]}) WHERE connection_info LIKE ${LIKE[$i]} and instance_uuid='$uuid'"
    done
done <instance_uuid

#!/bin/bash
set -x
source openrc.merg
nova list | awk '{print $2}' | grep -v ID > instance_uuid
USER='nova'
PASS='rMQ7CmIs'
DB='nova'

MONNEW=("'10.220.109.5'" "'10.220.109.8'" "'10.220.109.9'")
MONOLD=("'10.220.109.15'" "'10.220.109.16'" "'10.220.109.17'")
LIKE=("'%10.220.109.15%'" "'%10.220.109.16%'" "'%10.220.109.17%'")
while read uuid; do
  for i in {0..2};
    do
      mysql -h "localhost" -u "$USER" "-p$PASS" "$DB" -Bse "update block_device_mapping SET connection_info = REPLACE(connection_info, ${MONOLD[$i]}, ${MONNEW[$i]}) WHERE connection_info LIKE ${LIKE[$i]} and instance_uuid='$uuid'"
    done
done <instance_uuid
