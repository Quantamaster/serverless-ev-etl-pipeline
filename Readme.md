
# ⚡ Serverless EV Charging Infrastructure Analytics – ETL Pipeline
![AWS](https://img.shields.io/badge/AWS-Serverless-orange)
![S3](https://img.shields.io/badge/Amazon-S3-blue)
![Lambda](https://img.shields.io/badge/AWS-Lambda-yellow)
![Glue](https://img.shields.io/badge/AWS-Glue-green)
![Athena](https://img.shields.io/badge/Amazon-Athena-purple)
![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4)

A **fully automated, serverless ETL pipeline on AWS** for ingesting, transforming, and analyzing **electric vehicle (EV) charging session data**.  
Designed to demonstrate **modern cloud-native data engineering** using event-driven architecture and managed AWS services.

---
## 📚 Table of Contents

- [Overview](#-overview)
- [Tech Stack](#-tech-stack-badges)
- [Architecture](#-high-level-architecture)
- [System Design](#-system-design-flow)
- [ETL Pipeline Flow](#-etl-pipeline-flow)
- [AWS Services Used](#-aws-services-used)
- [Data Zones](#-data-zones)
- [Prerequisites](#-prerequisites)
- [Setup & Deployment](#-setup--deployment)
- [How the Pipeline Works](#-how-the-pipeline-works)
- [Querying with Amazon Athena](#-querying-with-amazon-athena)
- [Workflow Visualization](#-workflow-visualization)
- [Analytics Dashboard](#-analytics-dashboard)
- [Use Cases](#-use-cases)
- [Key Learnings](#-key-learnings-demonstrated)
- [Future Enhancements](#-future-enhancements)

---

## 📌 Overview
This project implements an **end-to-end serverless data pipeline** that processes raw EV charging session data and makes it analytics-ready for SQL querying and dashboards.

### Key Highlights
- Event-driven ingestion using **S3 + Lambda**
- Scalable ETL using **AWS Glue**
- Optimized storage using **Parquet + partitioning**
- Serverless analytics using **Amazon Athena**
- Infrastructure provisioned using **Terraform**

---

## 🏗️ High-Level Architecture

![Architecture Diagram](https://github.com/Quantamaster/serverless-ev-etl-pipeline/blob/main/Architecture.png)

---

## 🧠 System Design Flow

![Design Flowchart](https://github.com/Quantamaster/serverless-ev-etl-pipeline/blob/main/Design%20Flowchart.png)

---

## 🔄 ETL Pipeline Flow

```

CSV Upload (S3 Raw Zone)
↓
S3 Event Trigger
↓
AWS Lambda
↓
AWS Glue ETL Job
↓
Parquet Conversion + Partitioning
↓
S3 Curated Zone
↓
Amazon Athena (SQL Analytics)

````

---

## 🧱 AWS Services Used

| Service | Purpose |
|------|--------|
| Amazon S3 | Raw & processed data storage |
| AWS Lambda | Event-based ETL trigger |
| AWS Glue | Data transformation & schema enforcement |
| AWS IAM | Secure role-based access |
| Amazon Athena | Serverless SQL analytics |
| Terraform | Infrastructure as Code (IaC) |

---

## 📂 Data Zones

| Zone | S3 Bucket |
|----|----------|
| Raw Landing Zone | `ev-data-raw-data-landing` |
| Processed / Curated Zone | `ev-data-processed-data-curated` |

---

## ⚙️ Prerequisites

- AWS account with admin or sufficient IAM permissions
- AWS CLI configured (`aws configure`)
- Terraform installed locally

---

## 🚀 Setup & Deployment

### 1️⃣ Clone Repository
```bash
git clone https://github.com/your-username/serverless-ev-etl-pipeline.git
cd serverless-ev-etl-pipeline
````

---

### 2️⃣ Deploy Infrastructure (Terraform)

```bash
cd infrastructure
terraform init
terraform plan
terraform apply
```

This provisions:

* S3 buckets
* Lambda function
* Glue job
* IAM roles & policies

---

### 3️⃣ Upload Glue Script

```bash
aws s3 cp ../src/glue/ev_etl_script.py \
s3://ev-data-processed-data-curated/scripts/
```

---

### 4️⃣ Upload Sample EV Session Data

```bash
aws s3 cp ../data/sample_sessions.csv \
s3://ev-data-raw-data-landing/raw_sessions/
```

Uploading a CSV **automatically triggers the pipeline**.

---

## ▶ How the Pipeline Works

1. CSV file uploaded to **S3 Raw Zone**
2. **Lambda function** is triggered by S3 event
3. Lambda invokes **AWS Glue ETL job**
4. Glue:

   * Cleans & transforms data
   * Converts CSV → Parquet
   * Partitions by `date` and `station_id`
5. Processed data stored in **Curated S3 Zone**
6. Data becomes queryable in **Amazon Athena**

---

## 🔍 Querying with Amazon Athena

```sql
-- Total energy delivered per charging station
SELECT 
    station_id,
    SUM(energy_delivered_kwh) AS total_energy_kwh,
    COUNT(session_id) AS total_sessions
FROM processed_sessions
GROUP BY station_id
ORDER BY total_energy_kwh DESC;
```

---

## 🔁 Workflow Visualization

![Workflow](https://github.com/Quantamaster/serverless-ev-etl-pipeline/blob/main/electric-vehicle-charging-station-management.png)

---

## 📊 Analytics Dashboard

![Dashboard](https://github.com/Quantamaster/serverless-ev-etl-pipeline/blob/main/Dashboard.png)

---

## 🎯 Use Cases

* EV charging station utilization analysis
* Energy delivery and demand forecasting
* Infrastructure planning & optimization
* Smart city and sustainable mobility analytics

---

## 🧠 Key Learnings Demonstrated

* Serverless data engineering on AWS
* Event-driven ETL design
* Cloud cost-efficient analytics
* Infrastructure as Code (Terraform)
* Scalable & maintainable data pipelines

---

## 📈 Future Enhancements

* Add AWS QuickSight dashboard
* Implement data quality checks
* Add CI/CD for Terraform
* Support real-time streaming (Kinesis)
* Integrate ML-based demand forecasting

---

⭐ If this project helped your learning or portfolio, consider starring the repository!


