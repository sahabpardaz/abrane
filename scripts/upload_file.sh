#!/bin/bash

set -e

curl -i -X PUT -T $1 -H "content-type:application/octet-stream" "http://hdfs/api/v1/$2?op=CREATE&data=true&user.name=hadoop"
curl -i -X PUT "http://hdfs/api/v1/$2?user.name=hadoop&op=setowner&owner=spark"
