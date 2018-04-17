# Abrane

Abrane is a big-data as a service cloud which provides you with the required platforms and infrastructure to ingest, store, and process your data.

## Getting Started
### Connecting to Abrane
You can connect to Abrane using a VPN connection. Create a VPN connection with the L2TP as the protocol and provided credentials to "demo.abrane.ir". To test your setup ping check-ping.your-domain-name.abrane.ir. For your convinice, please set your search domain to your-domain-name.abrane.ir on this connection. You must now be able to ping check-ping with success. In the reset of this guide we assume such a setup or else append your-name.abrane.ir to the hostnames.

Note: After connecting to Abrane, your machine must be able to route 172.{16,17,18}.0.0/16 traffic through the VPN. If you have a different setup (e.g. a docker or vm bridge interface on these subnets) please correct your routing rules.

### A Step-by-Step guide to run a sample application
Now let's create a sample Spark application and deploy it to the Abrane. In this application we want to consume received messages from a Kafka topic and echo them to another Kafka topic.

1. Input

To ingest data into your cluster you can use the provided Kafka service for streaming ingestion or use the provided HDFS service for batch ingestion. In this example we use Kafka for streaming ingestion. As described in the Kafka service section, you can work with the Kafka service using its REST api or directly connect your Kafka producer to the exposed broker. Let's do the direct approach. For this end, you need a kafka distribution with version above 0.10 downloaded on your machine. Sending messages to the cluster is then easy:

```
.<kafka-home>/bin/kafka-console-producer.sh --broker-list kafka-1:9092,kafka-2:9092 --topic input
```

Note that the Kafka service is configured to automatically create topics with the required partitions and replicas (due to this, in your first message you might see LEADER_NOT_AVAILABLE warning which is not important). The configured Kafka keeps your data at least 3 days reliably.

2. Process

In the samples directory of this repo, there is a project named spark-stream-k2k which is a java-based Spark streaming application which consumes messages from a Kafka topic named "input" and produces the same message to a Kafka topic named "output". Now lets deploy and run this application on the cluster. First clone it:

```
git clone git@github.com:sahabpardaz/abrane.git
```

To build the project you need Maven >= 3 and JDK >= 8 installed on your machine.

```
cd abrane/samples/spark-stream-k2k
mvn clean package
```

The build process creates a jar named "sample-spark-stream-k2k-1.0-SNAPSHOT-jar-with-dependencies.jar" in the "target" directory. We must first upload it into the HDFS service. We use the provided webhdfs REST service for this. There is a script in the scripts directory which do this REST call.

```
./../../scripts/upload_file.sh "target/sample-spark-stream-k2k-1.0-SNAPSHOT-jar-with-dependencies.jar" "k2k-1.0.jar"
```

With our jar uploaded to HDFS with name "k2k_1.0.jar", we can run our Spark application using the provided Spark submission REST api. Again the submit_job.sh do the work for us.

```
./../../scripts/submit_job.sh "k2k-1.0.jar" "ir.sahab.abrane.sample.spark.k2k.Main"
```

As a shortuct of the above steps, you can call the run.sh script inside the spark-stream-k2k directory too which basically do the same steps.

In order to see your application metrics and logs, point your browser to http://spark-master/ and navigate to the Web UI of your application. You can also view your previouse application runs from http://spark-history/ address.

3. Output

Again, you can use Kafka or HDFS to retrieve your data from the cluster. For instance To consume your Kafka topics directly:

```
.<kafka-home>/bin/kafka-console-consumer.sh --bootstrap-server kafka-1:9092,kafka-2:9092 --topic output
```

Now sending some input from your producer, you must see them reprinted in the consumer too.


## Services
The following services are currently provided in Abrane.

### Kafka
* Installed Version: 0.10.2.1
* Brokers address: kafka-1:9092,kafka-2:9092
* REST: http://kafka/api/v2 ([Guide](https://docs.confluent.io/current/kafka-rest/docs/api.html#api-v2)) (will be available soon)

### HDFS
* Installed Version: 2.7.5
* Namenodes address (inside of cluster): hdfs-cluster:8020
* REST: http://hdfs/api/v1 ([Guide](https://hadoop.apache.org/docs/r2.7.5/hadoop-project-dist/hadoop-hdfs/WebHDFS.html))

### Spark
* Installed Version: 2.2.1
* REST: http://spark/api/v1 ([Guide](https://gist.github.com/arturmkrtchyan/5d8559b2911ac951d34a))
* Master UI: http://spark-master/
* History Server UI: http://spark-history/

### Zeppelin
* Installed Version: 0.7.3
* UI: http://zeppelin
