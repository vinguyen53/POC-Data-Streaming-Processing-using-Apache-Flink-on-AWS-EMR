import json
import boto3
import configparser
from random import randint
import time

#get config
config = configparser.ConfigParser()
config.read('init.ini')

#get step function arn
kinesis_name = config['kinesis']['name']

def generate_and_send_data (stream_name: str, partition_key: str, kinesis):
    for i in range(100,150):
        data = {'id':i, 'name': 'ntanvi', 'age': randint(1,100)}

        json_data = json.dumps(data)

        repsonse = kinesis.put_record(
            StreamName = stream_name,
            Data = json_data,
            PartitionKey = partition_key
        )

        print(f'data: {data}, response: {repsonse}')

        time.sleep(1)

def lambda_handler(event, context):
    kinesis = boto3.client('kinesis')
    generate_and_send_data(stream_name=kinesis_name,partition_key='ntanvi',kinesis=kinesis)


