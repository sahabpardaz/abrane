#!/bin/bash

curl -X POST http://spark.cb.abrane.ir/api/v1/submissions/create --header "Content-Type:application/json;charset=UTF-8" --data '{
  "action" : "CreateSubmissionRequest",
  "appArgs" : [ "sample-app-arg" ],
  "appResource" : "hdfs://master-11:8020/$1",
  "clientSparkVersion" : "1.5.0",
  "environmentVariables" : {
    "SPARK_ENV_LOADED" : "1"
  },
  "mainClass" : "$2",
  "sparkProperties" : {
    "spark.jars" : "hdfs://master-11:8020/$1",
    "spark.driver.supervise" : "true",
    "spark.app.name" : "submitted job",
    "spark.submit.deployMode" : "cluster",
    "spark.master" : "spark://master-11:6066,master-21:6066",
    "spark.logConf": "true",
    "spark.eventLog.enabled": "true",
    "spark.eventLog.dir": "hdfs://master-11:8020/spark/logs"
  }
}'
