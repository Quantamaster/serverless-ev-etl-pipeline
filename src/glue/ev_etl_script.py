import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.functions import col, unix_timestamp, when, to_date
from pyspark.sql.types import TimestampType

## @params: ['JOB_NAME', 'RAW_S3_PATH', 'TARGET_S3_PATH']
args = getResolvedOptions(sys.argv, ['JOB_NAME', 'RAW_S3_PATH', 'TARGET_S3_PATH'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# 1. Read raw CSV data from the path provided by Lambda
raw_dynamic_frame = glueContext.create_dynamic_frame.from_options(
    format_options={"quoteChar": '"', "withHeader": True, "separator": ","},
    connection_type="s3",
    format="csv",
    connection_options={"paths": [args['RAW_S3_PATH']], "recurse": True},
    transformation_ctx="raw_dynamic_frame",
)

# Convert to Spark DataFrame for easier transformations
df = raw_dynamic_frame.toDF()

# 2. Perform Transformations
processed_df = (df
    .withColumn("start_time", col("start_time").cast(TimestampType()))
    .withColumn("end_time", col("end_time").cast(TimestampType()))
    .withColumn("energy_delivered_kwh", col("energy_delivered_kwh").cast("double"))
    .withColumn("session_duration_sec", unix_timestamp(col("end_time")) - unix_timestamp(col("start_time")))
    .withColumn("date", to_date(col("start_time")))  # Partition column
    .withColumn("utilization_status", 
                when(col("session_duration_sec") > 3600, "LONG_SESSION").otherwise("SHORT_SESSION"))
)

# 3. Write the transformed data as Parquet, partitioned by date and station_id
(processed_df.write
    .mode("append")
    .format("parquet")
    .partitionBy("date", "station_id")
    .save(args['TARGET_S3_PATH'])
)

job.commit()
