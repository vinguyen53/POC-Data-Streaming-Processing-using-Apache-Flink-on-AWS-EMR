# POC-Data-Streaming-Processing-using-Apache-Flink-on-AWS-EMR
## Data Architecture
<img width="572" alt="image" src="https://github.com/user-attachments/assets/16f1e7ed-ae85-4989-a343-d1b59ec4284e">


- Data source: using Lambda Function (with Python) to create message and push to Kinesis Data Stream, act as a streaming source
- Step Funtions execute following sequence: create EMR cluster,then submit Flink Streaming job
- EMR cluster is created with Flink, using Glue catalog for data catalog
- Any message is pushed into Kinesis Data Stream, immediately read by Flink then upsert into Iceberg table
- Using Athena for query data
