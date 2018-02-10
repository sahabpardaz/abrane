package ir.sahab.abrane.sample.spark.k2k;

import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.apache.kafka.common.serialization.StringSerializer;
import org.apache.spark.SparkConf;
import org.apache.spark.streaming.Duration;
import org.apache.spark.streaming.api.java.JavaInputDStream;
import org.apache.spark.streaming.api.java.JavaStreamingContext;
import org.apache.spark.streaming.kafka010.CanCommitOffsets;
import org.apache.spark.streaming.kafka010.ConsumerStrategies;
import org.apache.spark.streaming.kafka010.HasOffsetRanges;
import org.apache.spark.streaming.kafka010.KafkaUtils;
import org.apache.spark.streaming.kafka010.LocationStrategies;
import org.apache.spark.streaming.kafka010.OffsetRange;

import java.util.Collections;
import java.util.HashMap;

/**
 * A sample spark streaming application which reads from a kafka topic named input and echos it into
 * a kafka topic named output. The application guarantees at-least-once processing.
 */
public class Main {

    public static final String KAFKA_SERVERS = "kafka-1:9092,kafka-2:9092";

    // One kafkaProducer per executor is enough since it is thread-safe
    public static class KafkaWriter {
        private transient KafkaProducer<String, String> producer;

        private static KafkaWriter instance;

        public static KafkaWriter getInstance() {
            if (instance == null) {
                instance = new KafkaWriter();
            }
            return instance;
        }

        public KafkaWriter() {
            HashMap<String, Object> params = new HashMap<>();
            params.put("bootstrap.servers", KAFKA_SERVERS);
            params.put("key.serializer", StringSerializer.class);
            params.put("value.serializer", StringSerializer.class);
            // Since our spark job is also in the order of one second and we call flush manually,
            // we can wait more here
            params.put("linger.ms", 2000);
            producer = new KafkaProducer<>(params);
        }

        public KafkaProducer<String, String> getProducer() {
            return producer;
        }
    }

    public static void main(String[] args) throws InterruptedException {
        SparkConf sparkConf = new SparkConf().setAppName("Sample k2k Stream");
        /**
         * You can run the driver locally too by enabling the blow line. Just ensure that your dns
         * search domain is set to your-name.abrane.ir or change KAFKA_SERVERS to
         * stream-11.your-name.abrane.ir:9092,...
         * Also you might need to change your pom.xml and change provided scope to compile
         * temporarily
         */
        //sparkConf.setMaster("local[2]");
        try (JavaStreamingContext streamingContext = new JavaStreamingContext(
                     sparkConf, new Duration(1000))) {

            HashMap<String, Object> kafkaConsumerParam = new HashMap<>();
            kafkaConsumerParam.put("bootstrap.servers", KAFKA_SERVERS);
            kafkaConsumerParam.put("key.deserializer", StringDeserializer.class);
            kafkaConsumerParam.put("value.deserializer", StringDeserializer.class);
            kafkaConsumerParam.put("group.id", "k2k");
            kafkaConsumerParam.put("auto.offset.reset", "latest");
            // To guarantee at least once we need to set this to false
            kafkaConsumerParam.put("enable.auto.commit", false);

            JavaInputDStream<ConsumerRecord<String, String>> stream =
                    KafkaUtils.createDirectStream(
                            streamingContext,
                            LocationStrategies.PreferConsistent(),
                            ConsumerStrategies.<String, String>Subscribe(
                                    Collections.singletonList("input"),
                                    kafkaConsumerParam)
                    );

            stream.foreachRDD(rdd -> {
                OffsetRange[] offsetRanges = ((HasOffsetRanges) rdd.rdd()).offsetRanges();

                rdd.map(ConsumerRecord::value).foreachPartition(part -> {
                    KafkaProducer<String, String> producer = KafkaWriter.getInstance().getProducer();
                    while(part.hasNext()) {
                        String data = part.next();
                        producer.send(new ProducerRecord<>("output", null, data));
                    }
                    producer.flush();
                });

                ((CanCommitOffsets) stream.inputDStream()).commitAsync(offsetRanges);
            });

            streamingContext.start();
            streamingContext.awaitTermination();
            // We don't close producers properly, that's ok
        }
    }
}
