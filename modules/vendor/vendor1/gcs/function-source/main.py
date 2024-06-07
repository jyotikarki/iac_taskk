import base64
import logging
import os
import re
import traceback
import warnings
import yaml
from google.cloud import bigquery
from google.cloud import storage
from google.cloud import exceptions

# Import Cloud Functions framework
import functions_framework

# Load the schema configuration
with open("./schemas.yaml") as schema_file:
    config = yaml.load(schema_file, Loader=yaml.Loader)

# Set up Google Cloud clients
PROJECT_ID = os.getenv('GCP_PROJECT', 'itsme-1234')  # Default to 'itsme-1234' if GCP_PROJECT env var is not set
BQ_DATASET = 'vendor1_bq_dataset_v1'
CS = storage.Client()
BQ = bigquery.Client()
job_config = bigquery.LoadJobConfig()

# Function to handle CSV processing logic
def process_csv(bucket_name, file_name):
    try:
        bucket = CS.bucket(bucket_name)
        blob = bucket.blob(file_name)
        content = blob.download_as_text()

        # Process the CSV content
        print(f"Processing CSV file: {file_name}")
        print("======================")
        print(content)

        # Your CSV processing logic goes here
        for table in config:
            tableName = table.get('name')
            if re.search(tableName.replace('_', '-'), file_name) or re.search(tableName, file_name):
                tableSchema = table.get('schema')
                _check_if_table_exists(tableName, tableSchema)
                tableFormat = table.get('format')
                if tableFormat == 'CSV':
                    _load_table_from_uri(bucket_name, file_name, tableSchema, tableName)
    except Exception as e:
        print(f"Error processing CSV file: {e}")

# Function to check if BigQuery table exists and create if not
def _check_if_table_exists(tableName, tableSchema):
    table_id = BQ.dataset(BQ_DATASET).table(tableName)
    
    try:
        BQ.get_table(table_id)
        print(f"Table {table_id} already exists.")
    except exceptions.NotFound:
        warnings.warn(f"Table {tableName} does not exist. Creating table.")
        schema = create_schema_from_yaml(tableSchema)
        table = bigquery.Table(table_id, schema=schema)
        table = BQ.create_table(table)
        print(f"Created table {table.project}.{table.dataset_id}.{table.table_id}")
    except Exception as e:
        print(f"Error checking table existence: {e}")

# Function to load data into BigQuery from GCS URI
def _load_table_from_uri(bucket_name, file_name, tableSchema, tableName):
    uri = f'gs://{bucket_name}/{file_name}'
    table_id = BQ.dataset(BQ_DATASET).table(tableName)

    schema = create_schema_from_yaml(tableSchema)
    print(f"Schema: {schema}")
    job_config.schema = schema

    job_config.source_format = bigquery.SourceFormat.CSV
    job_config.write_disposition = bigquery.WriteDisposition.WRITE_APPEND
    job_config.skip_leading_rows = 1  # Skip header row

    load_job = BQ.load_table_from_uri(
        uri,
        table_id,
        job_config=job_config,
    )
    
    load_job.result()  # Waits for the job to complete
    print("Job finished.")

# Function to create schema from YAML configuration
def create_schema_from_yaml(table_schema):
    schema = []
    for column in table_schema:
        schemaField = bigquery.SchemaField(column['name'], column['type'], column['mode'])
        schema.append(schemaField)

        if column['type'] == 'RECORD':
            schemaField.fields = create_schema_from_yaml(column['fields'])
    return schema

# Triggered by a message on a Pub/Sub topic
@functions_framework.cloud_event
def hello_pubsub(cloud_event):
    try:
        data = cloud_event.data
        pubsub_message = base64.b64decode(data["message"]["data"]).decode('utf-8')
        
        message_dict = yaml.safe_load(pubsub_message)  # Assuming the message is YAML-formatted; use json.loads if JSON-formatted
        bucket = message_dict.get("bucket")
        name = message_dict.get("name")

        print(f"Received message: {pubsub_message}")
        print(f"Bucket: {bucket}")
        print(f"File: {name}")

        process_csv(bucket, name)
    except Exception as e:
        print(f"Error handling Pub/Sub message: {e}")
