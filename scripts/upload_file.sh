#!/bin/bash


curl -i -X PUT -T $1 -H "content-type:application/octet-stream" http://hdfs.cb.abrane.ir/webhdfs/v1/$2?op=CREATE&data=true&user.name=hadoop"

curl -i -X PUT "http://hdfs.cb.abrane.ir/webhdfs/v1/$2?user.name=hadoop&op=setowner&owner=spark"
