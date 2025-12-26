# Serverless EV Charging Infra Analytics ETL Pipeline

A fully automated, serverless ETL pipeline for processing electric vehicle charging session data on AWS.

## Architecture

![Architecture Diagram](architecture.png)

The pipeline consists of the following components:

1. **S3 Landing Zone**: Raw CSV files are uploaded to `ev-data-raw-data-landing`
2. **AWS Lambda**: Triggered by S3 upload events to start the ETL process
3. **AWS Glue**: Performs ETL transformations and converts data to Parquet format
4. **S3 Processed Zone**: Transformed, partitioned data stored in `ev-data-processed-data-curated`
5. **AWS Athena**: Used to query the processed data with SQL

## Services Used

- Amazon S3
- AWS Lambda
- AWS Glue
- AWS IAM
- Amazon Athena

## Setup and Deployment

### Prerequisites

- AWS account with appropriate permissions
- Terraform installed locally
- AWS CLI configured

### Deployment Steps

1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/serverless-ev-etl-pipeline.git
   cd serverless-ev-etl-pipeline
2.Initialize and apply Terraform configuration:

bash
cd infrastructure
terraform init
terraform plan
terraform apply
3.Upload the Glue script to S3:

bash
aws s3 cp ../src/glue/ev_etl_script.py s3://ev-data-processed-data-curated/scripts/
4.Upload sample data to test the pipeline:

bash
aws s3 cp ../data/sample_sessions.csv s3://ev-data-raw-data-landing/raw_sessions/
5.How to Use
Upload CSV files to the raw data S3 bucket in the raw_sessions/ prefix

The Lambda function will automatically trigger the Glue job

Processed data will be available in the processed data bucket, partitioned by date and station_id

6.Query the data using Amazon Athena:

sql
-- Total energy delivered per station
SELECT station_id, 
       SUM(energy_delivered_kwh) as total_energy_kwh,
       COUNT(session_id) as total_sessions
FROM processed_sessions
GROUP BY station_id
ORDER BY total_energy_kwh DESC;
