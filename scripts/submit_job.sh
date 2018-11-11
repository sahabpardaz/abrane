#!/bin/bash

if [[ $# -ne 2 ]]; then
  echo "Usage: submit_job <file-path-in-hdfs> <main-class-full-name>"
  exit 1
fi

curl -X POST http://spark/api/v1/submissions/create --header "Content-Type:application/json;charset=UTF-8" --data '{
  "action" : "CreateSubmissionRequest",
  "appArgs" : [ "sample-app-arg" ],
  "appResource" : "hdfs://nn-cluster:8020/'"$1"'",
  "clientSparkVersion" : "1.5.0",
  "environmentVariables" : {
    "SPARK_ENV_LOADED" : "1"
  },
  "mainClass" : "'"$2"'",
  "sparkProperties" : {
    "spark.jars" : "hdfs://nn-cluster:8020/'"$1"'",
    "spark.app.name" : "submitted job",
    "spark.submit.deployMode" : "cluster",
    "spark.driver.supervise" : "true",
    "spark.master" : "spark://spark-master-1:6066,spark-master-2:6066",
    "spark.logConf": "true",
    "spark.executor.logs.rolling.strategy": "time",
    "spark.executor.logs.rolling.maxRetainedFiles": 5,
    "spark.eventLog.enabled": "true",
    "spark.eventLog.dir": "hdfs://nn-cluster:8020/spark/logs",
    "spark.serializer": "org.apache.spark.serializer.KryoSerializer",
    "spark.ui.reverseProxy": "true",
    "spark.streaming.backpressure.enabled": "true",
    "spark.streaming.kafka.maxRatePerPartition": 10000,
    "spark.streaming.receiver.maxRate": 10000
  }
}'
      