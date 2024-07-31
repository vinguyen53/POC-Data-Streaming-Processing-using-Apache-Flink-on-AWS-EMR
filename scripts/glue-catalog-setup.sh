set -ex

sudo cp /usr/lib/hive/auxlib/aws-glue-datacatalog-hive3-client.jar /usr/lib/flink/lib 
sudo cp /usr/lib/hive/lib/antlr-runtime-3.5.2.jar /usr/lib/flink/lib 
sudo cp /usr/lib/hive/lib/hive-exec-3.1.3*.jar /lib/flink/lib 
sudo cp /usr/lib/hive/lib/libfb303-0.9.3.jar /lib/flink/lib 
sudo cp /usr/lib/flink/opt/flink-connector-hive_2.12-1.1*.jar /lib/flink/lib
sudo chmod 755 /usr/lib/flink/lib/aws-glue-datacatalog-hive3-client.jar 
sudo chmod 755 /usr/lib/flink/lib/antlr-runtime-3.5.2.jar 
sudo chmod 755 /usr/lib/flink/lib/hive-exec-3.1.3*.jar 
sudo chmod 755 /usr/lib/flink/lib/libfb303-0.9.3.jar
sudo chmod 755 /usr/lib/flink/lib/flink-connector-hive_2.12-1.1*.jar

sudo mv /usr/lib/flink/opt/flink-table-planner_2.12-1.18.1*.jar /usr/lib/flink/lib/
sudo mv /usr/lib/flink/lib/flink-table-planner-loader-1.18.1*.jar /usr/lib/flink/opt/

sudo wget https://repo1.maven.org/maven2/org/apache/flink/flink-sql-parquet/1.18.1/flink-sql-parquet-1.18.1.jar -O /usr/lib/flink/lib/flink-sql-parquet-1.18.1.jar
sudo chmod 755 /usr/lib/flink/lib/flink-sql-parquet-1.18.1.jar

sudo wget https://repo1.maven.org/maven2/org/apache/flink/flink-parquet/1.18.1/flink-parquet-1.18.1.jar -O /usr/lib/flink/lib/flink-parquet-1.18.1.jar
sudo chmod 755 /usr/lib/flink/lib/flink-parquet-1.18.1.jar

sudo wget https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-kinesis/4.3.0-1.18/flink-sql-connector-kinesis-4.3.0-1.18.jar -O /usr/lib/flink/lib/flink-sql-connector-kinesis-4.3.0-1.18.jar
sudo chmod 755 /usr/lib/flink/lib/flink-sql-connector-kinesis-4.3.0-1.18.jar

sudo aws s3 cp s3://ntanvi-sfn-emr-demo/scripts/flink_sql_iceberg.sql /root/flink_sql_iceberg.sql
sudo chmod 755 /root/flink_sql_iceberg.sql