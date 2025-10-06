output "raw_data_bucket_name" {
  description = "Name of the raw data S3 bucket"
  value       = aws_s3_bucket.raw_data_landing.bucket
}

output "processed_data_bucket_name" {
  description = "Name of the processed data S3 bucket"
  value       = aws_s3_bucket.processed_data_curated.bucket
}

output "glue_job_name" {
  description = "Name of the Glue ETL job"
  value       = aws_glue_job.ev_etl_job.name
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.trigger_glue_job.function_name
}
