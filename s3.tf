#Create S3 bucket
resource "aws_s3_bucket" "s3" {
  bucket = "ntanvi-sfn-emr-demo"
}

#Upload scripts
resource "aws_s3_object" "flink-sql" {
  bucket = aws_s3_bucket.s3.id
  key    = "scripts/flink_sql_iceberg.sql"
  source = "./scripts/flink_sql_iceberg.sql"
  etag = filemd5("./scripts/flink_sql_iceberg.sql")
}

resource "aws_s3_object" "s3-hive" {
  bucket = aws_s3_bucket.s3.id
  key    = "scripts/pyspark_hive.py"
  source = "./scripts/pyspark_hive.py"
  etag = filemd5("./scripts/pyspark_hive.py")
}


