#!/bin/bash

if [[ $# -ne 2 ]]; then
  echo "Usage: upload_file <path-to-file> <file-path-in-hdfs>"
  exit 1
fi

set -e

curl -i -X PUT -T $1 -H "content-type:application/octet-stream" "http://hdfs/api/v1/$2?op=CREATE&data=true&user.name=hadoop"
curl -i -X PUT "http://hdfs/api/v1/$2?user.name=hadoop&op=setowner&owner=spark"
