#!/bin/bash

set -e

echo "Building ..."
mvn clean package

echo "Uploading ..."
./../../scripts/upload_file.sh "target/sample-spark-stream-k2k-1.0-SNAPSHOT-jar-with-dependencies.jar" "k2k-1.0.jar"

echo "Submitting ..."
./../../scripts/submit_job.sh "k2k-1.0.jar" "ir.sahab.abrane.sample.spark.k2k.Main"
