#!/bin/bash

USER=`id -u -n`
HOST=`hostname`
DIR="/tmp/mongodb-$USER-$HOST"
LOGDIR="$HOME/mongodb-logs/access-logs"

#Delete the directory if it is existing
rm -rf $DIR

#Create new directory for mongodb data
mkdir $DIR

mkdir -p $LOGDIR

export PATH=$PATH:$1:

#$2 is the port on which we want to run mongod
#nohup will run the mongod in background and store logs in $LOGDIR
nohup mongod --dbpath $DIR --port $2 > "$LOGDIR/mongod-$HOST.log" &
