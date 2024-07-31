--create hive catalog
CREATE CATALOG glue_catalog_for_hive WITH (
          'type' = 'hive',
          'default-database' = 'default',
          'hive-conf-dir' = '/etc/hive/conf.dist'
          );

use catalog glue_catalog_for_hive;

--create hive database
CREATE DATABASE IF NOT EXISTS flink_hive_db WITH ('hive.database.location-uri'= 's3://ntanvi-sfn-emr-demo/flink_hive/warehouse/');

use flink_hive_db;

--create kinesis source table
create table if not exists kinesis_table(
    id int,
    name string,
    age int,
    arrival_time timestamp metadata from 'timestamp' virtual,
    sequence_number string metadata from 'sequence-number' virtual
)
with (
    'connector' = 'kinesis',
    'stream' = 'demo-kinesis',
    'scan.stream.initpos' = 'TRIM_HORIZON',
    'aws.region' = 'ap-southeast-1',
    'format' = 'json'
);

--create iceberg catalog
CREATE CATALOG glue_catalog_for_iceberg WITH (
'type'='iceberg',
'warehouse'='s3://ntanvi-sfn-emr-demo/flink-iceberg/warehouse/',
'catalog-impl'='org.apache.iceberg.aws.glue.GlueCatalog',
'io-impl'='org.apache.iceberg.aws.s3.S3FileIO');

use catalog glue_catalog_for_iceberg;

--create iceberg database
create database if not exists flink_iceberg_db;

use flink_iceberg_db;

--create iceberg table target with upsert mode
CREATE TABLE IF NOT EXISTS kinesis_iceberg_table (
            id int,
            name string,
            age int,
            arrival_time timestamp,
            sequence_number string,
            primary key (id) not Enforced
          ) WITH (
            'format-version' = '2',
            'write.upsert.enabled' = 'true'
          );

SET 'execution.runtime-mode' = 'streaming';
SET 'table.dml-sync' = 'true';

--upsert data from kinesis into iceberg table
INSERT INTO glue_catalog_for_iceberg.flink_iceberg_db.kinesis_iceberg_table select * from glue_catalog_for_hive.flink_hive_db.kinesis_table; 