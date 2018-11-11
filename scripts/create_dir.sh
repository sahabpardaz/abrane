#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "Usage: create_dir <dir-path>"
  exit 1
fi

set -e

curl -i -X DELETE "http://hdfs/api/v1$1?user.name=hadoop&op=DELETE&recursive=true"
curl -i -X PUT "http://hdfs/api/v1$1?user.name=hadoop&op=MKDIRS"
curl -i -X PUT "http://hdfs/api/v1$1?user.name=hadoop&op=setowner&owner=spark"
