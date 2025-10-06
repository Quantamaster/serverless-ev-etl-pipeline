import boto3
import urllib.parse

def lambda_handler(event, context):
    glue_client = boto3.client('glue')
    
    # Get the bucket and key from the S3 event trigger
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    
    raw_s3_path = f"s3://{bucket}/{key}"
    
    # Start the Glue Job, passing the source file path
    try:
        response = glue_client.start_job_run(
            JobName = 'ev-station-etl-job',
            Arguments = {
                '--RAW_S3_PATH': raw_s3_path,
                '--TARGET_S3_PATH': 's3://ev-processed-data-curated/processed_sessions/'
            }
        )
        print(f"Started Glue Job Run ID: {response['JobRunId']}")
        print(f"Processing file: {raw_s3_path}")
        return response
    except Exception as e:
        print(e)
        raise e
