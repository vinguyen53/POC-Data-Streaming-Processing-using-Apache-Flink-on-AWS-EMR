#Create step function
resource "aws_sfn_state_machine" "sfn_emr" {
  name = "demo-sfn-emr"
  role_arn = aws_iam_role.sfn_role.arn
  definition = <<EOF
    {
  "Comment": "An example of the Amazon States Language for running jobs on Amazon EMR",
  "StartAt": "Create an EMR cluster",
  "States": {
    "Create an EMR cluster": {
      "Type": "Task",
      "Resource": "arn:aws:states:::elasticmapreduce:createCluster.sync",
      "Parameters": {
        "Name": "demo-sfn-emr-cluster",
        "VisibleToAllUsers": true,
        "ReleaseLabel": "emr-7.1.0",
        "Applications": [
          {
            "Name": "Hadoop"
          },
          {
            "Name": "Flink"
          },
          {
            "Name": "Hive"
          }
        ],
        "ServiceRole": "${aws_iam_role.emr_service_role.name}",
        "JobFlowRole": "${aws_iam_role.emr_profile_role.name}",
        "LogUri": "s3://ntanvi-sfn-emr-demo/logs",
        "Instances": {
          "KeepJobFlowAliveWhenNoSteps": true,
          "AdditionalMasterSecurityGroups": ["${aws_security_group.emr-master-sg.id}"],
          "Ec2SubnetId": "${aws_subnet.emr-subnet.id}",
          "InstanceGroups": [
            {
              "InstanceCount": 1,
              "InstanceRole": "MASTER",
              "InstanceType": "m5.xlarge"
            },
            {
              "InstanceCount": 1,
              "InstanceRole": "CORE",
              "InstanceType": "m5.xlarge"
            }
          ]
        },
        "Configurations": [
            {
              "Classification": "iceberg-defaults",
              "Properties": {
                "iceberg.enabled": "true"
              }
            },
            {
              "Classification": "flink-conf",
              "Properties": {
                "python.client.executable": "python3",
                "python.executable": "python3"
              }
            },
            {
              "Classification": "hive-site",
              "Properties": {
                "hive.metastore.client.factory.class": "com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory"
              }
            }
          ]
      },
      "ResultPath": "$.cluster",
      "Next": "custom jar"
    },
    "custom jar": {
      "Type": "Task",
      "Resource": "arn:aws:states:::elasticmapreduce:addStep.sync",
      "Parameters": {
        "ClusterId.$": "$.cluster.ClusterId",
        "Step": {
          "Name": "custom jar file",
          "ActionOnFailure": "CONTINUE",
          "HadoopJarStep": {
            "Jar": "s3://ap-southeast-1.elasticmapreduce/libs/script-runner/script-runner.jar",
            "Args": ["s3://${aws_s3_bucket.s3.id}/scripts/glue-catalog-setup.sh"]
          }
        }
      },
      "Retry": [
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "IntervalSeconds": 1,
          "MaxAttempts": 3,
          "BackoffRate": 2
        }
      ],
      "ResultPath": "$.customJarStep",
      "Next": "flink session"
    },
    "flink session": {
      "Type": "Task",
      "Resource": "arn:aws:states:::elasticmapreduce:addStep.sync",
      "Parameters": {
        "ClusterId.$": "$.cluster.ClusterId",
        "Step": {
          "Name": "create flink session",
          "ActionOnFailure": "CONTINUE",
          "HadoopJarStep": {
            "Jar": "command-runner.jar",
            "Args": [
              "sudo flink-yarn-session -d -jm 2048 -tm 4096 -s 2",
              "-D state.backend=rocksdb",
              "-D state.backend.incremental=true",
              "-D state.checkpoint-storage=filesystem",
              "-D state.checkpoints.dir=s3://${aws_s3_bucket.s3.id}/flink-checkpoints/",
              "-D state.checkpoints.num-retained=1",
              "-D execution.checkpointing.interval=30s",
              "-D execution.checkpointing.mode=EXACTLY_ONCE",
              "-D execution.checkpointing.externalized-checkpoint-retention=RETAIN_ON_CANCELLATION",
              "-D execution.checkpointing.max-concurrent-checkpoints=1"
            ]
          }
        }
      },
      "Retry": [
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "IntervalSeconds": 1,
          "MaxAttempts": 3,
          "BackoffRate": 2
        }
      ],
      "ResultPath": "$.flinkSessionStep",
      "Next": "flink job"
    },
    "flink job": {
      "Type": "Task",
      "Resource": "arn:aws:states:::elasticmapreduce:addStep.sync",
      "Parameters": {
        "ClusterId.$": "$.cluster.ClusterId",
        "Step": {
          "Name": "submit flink sql job",
          "ActionOnFailure": "CONTINUE",
          "HadoopJarStep": {
            "Jar": "command-runner.jar",
            "Args": [
              "sudo /usr/lib/flink/bin/sql-client.sh embedded -f /root/flink_sql_iceberg.sql"
            ]
          }
        }
      },
      "Retry": [
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "IntervalSeconds": 1,
          "MaxAttempts": 3,
          "BackoffRate": 2
        }
      ],
      "ResultPath": "$.flinkJobStep",
      "Next": "Terminate Cluster"
    },
    "Terminate Cluster": {
      "Type": "Task",
      "Resource": "arn:aws:states:::elasticmapreduce:terminateCluster",
      "Parameters": {
        "ClusterId.$": "$.cluster.ClusterId"
      },
      "End": true
    }
  }
}
  EOF
}