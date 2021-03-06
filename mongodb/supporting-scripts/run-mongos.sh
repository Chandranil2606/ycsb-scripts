#!/bin/bash

HOST=`hostname`
LOGDIR="$HOME/mongodb-logs"

#Delete the directory if it is existing
rm -rf $DIR

#Creates directory for logging if it does not exists
mkdir -p $LOGDIR

export PATH=$PATH:$1:

#$2 is the port on which we want to run mongod are running while on
#$3 mongos will run nohup will run the mongod in background and 
#store logs in $LOGDIR
#mongos --configdb compg4:2010,compg6:2010,compg7:2010 --port 2014
nohup mongos --config mongodb.conf --configdb compg4:$2,compg6:$2,compg7:$2 --port $3 > "$LOGDIR/mongos-$HOST.log" &
#mongos --configdb 192.168.8.215:$2,192.168.8.210:$2,192.168.8.206:$2 --port $3 #> "$LOGDIR/mongos-$HOST.log"

sleep 10

echo "Adding compg4 to shards"
mongo --port $3 --eval "sh.addShard('compg4:$2')"

echo "Adding compg6 to shards"
mongo --port $3 --eval "sh.addShard('compg6:$2')"

echo "Adding compg7 to shards"
mongo --port $3 --eval "sh.addShard('compg7:$2')"

echo "Creating database: test"
mongo --port $3 --eval "use test"

echo "Creating collection: usertable"
mongo --port $3 --eval "db.createCollection('usertable')"

echo "Enabling Sharding"
mongo --port $3 --eval "sh.enableSharding('test')"

echo "Add index over which sharding has to happen"
mongo --port $3 --eval "db.usertable.ensureIndex({ _id: 'hashed'})"

echo "Sharding collection"
mongo --port $3 --eval "sh.shardCollection('test.usertable', {'_id':'hashed'})"

