provider "aws" {
  region = var.aws_region
}

# S3 Buckets
resource "aws_s3_bucket" "raw_data_landing" {
  bucket = "${var.s3_bucket_prefix}-raw-data-landing"
  force_destroy = true
}

resource "aws_s3_bucket" "processed_data_curated" {
  bucket = "${var.s3_bucket_prefix}-processed-data-curated"
  force_destroy = true
}

# IAM Role for Glue
resource "aws_iam_role" "glue_service_role" {
  name = "AWSGlueServiceRole-EV-ETL"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_service_role" {
  role       = aws_iam_role.glue_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "glue_s3_access" {
  name = "GlueEVETL-S3-Logs-Catalog-Access"
  role = aws_iam_role.glue_service_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "${aws_s3_bucket.raw_data_landing.arn}/*",
          "${aws_s3_bucket.processed_data_curated.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.raw_data_landing.arn,
          aws_s3_bucket.processed_data_curated.arn
        ]
      }
    ]
  })
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_execution_role" {
  name = "Lambda-EV-Trigger-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "Lambda-EV-Trigger-Policy"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "glue:StartJobRun"
        ]
        Resource = "arn:aws:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:job/ev-station-etl-job"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.raw_data_landing.arn}/*"
      }
    ]
  })
}

# AWS Glue Job
resource "aws_glue_job" "ev_etl_job" {
  name     = "ev-station-etl-job"
  role_arn = aws_iam_role.glue_service_role.arn

  command {
    script_location = "s3://${aws_s3_bucket.processed_data_curated.bucket}/scripts/ev_etl_script.py"
  }

  default_arguments = {
    "--job-language" = "python"
  }
}

# AWS Lambda Function
resource "aws_lambda_function" "trigger_glue_job" {
  filename      = "${path.module}/../src/lambda/trigger_glue_job.zip"
  function_name = "ev-trigger-glue-job"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "trigger_glue_job.lambda_handler"
  runtime       = "python3.9"

  environment {
    variables = {
      GLUE_JOB_NAME = aws_glue_job.ev_etl_job.name
    }
  }
}

# S3 Event Notification for Lambda
resource "aws_s3_bucket_notification" "raw_bucket_notification" {
  bucket = aws_s3_bucket.raw_data_landing.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.trigger_glue_job.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "raw_sessions/"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.trigger_glue_job.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.raw_data_landing.arn
}

data "aws_caller_identity" "current" {}
