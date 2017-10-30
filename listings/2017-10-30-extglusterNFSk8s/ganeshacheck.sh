#!/bin/sh

# Check if mongo is running
ps aux | grep ganesha.nfsd | grep -v grep > /dev/null
RESULT=$?   # returns 0 if mongo eval succeeds

if [ $RESULT -ne 0 ]; then
    echo "ganesha is not running"
    logger "ganesha is not running, keepalived start is declined"
    exit 1
else
    echo "ganesha is running!"
    logger "ganesha is running, grant permission for keepalived"
fi

if [ $? != 0 ]
then
        exit 1
fi
