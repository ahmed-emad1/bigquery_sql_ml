# BigQuery Data Warehouse Project

This project demonstrates best practices for working with BigQuery, focusing on partitioning, clustering, and the internals of BigQuery. It also covers deploying and using a machine learning model trained within BigQuery.

## Project Components
- **Data Warehouse:** Implement a scalable data warehouse using Google BigQuery.
- **BigQuery Partitioning & Clustering:** Use partitioning and clustering techniques to optimize query performance and cost efficiency.
- **BigQuery Machine Learning (BQML):** Train and deploy machine learning models directly from BigQuery.

## Setup Instructions

1. Replace `terraform-demo-435114` with your **BigQuery project ID** and `demo_dataset` with your **BigQuery dataset name** in the provided SQL files.
   
2. To download and run the trained model locally, follow the steps below.

## Model Deployment

Follow [this tutorial](https://cloud.google.com/bigquery-ml/docs/export-model-tutorial) for deploying a machine learning model from BigQuery.

### Steps:

1. **Authenticate with Google Cloud:**
   ```
   gcloud auth login
   ```

2. **Extract the model from BigQuery:**
   ```
   bq --project_id terraform-demo-435114 extract -m demo_dataset.tip_model gs://taxi_ml_model/tip_model
   ```

3. **Download the model files locally:**
   ```
   mkdir /tmp/model
   gsutil cp -r gs://taxi_ml_model/tip_model /tmp/model
   ```

4. **Prepare the serving directory:**
   ```
   mkdir -p serving_dir/tip_model/1
   cp -r /tmp/model/tip_model/* serving_dir/tip_model/1
   ```

5. **Pull TensorFlow Serving Docker image:**
   ```
   docker pull tensorflow/serving
   ```

6. **Run the model locally with TensorFlow Serving:**
   ```
   docker run -p 8501:8501 --mount type=bind,source=`pwd`/serving_dir/tip_model,target=/models/tip_model -e MODEL_NAME=tip_model -t tensorflow/serving &
   ```

7. **Test the model using a sample input:**
   ```
   curl -d '{"instances": [{"passenger_count":1, "trip_distance":12.2, "PULocationID":"193", "DOLocationID":"264", "payment_type":"2", "fare_amount":20.4, "tolls_amount":0.0}]}' -X POST http://localhost:8501/v1/models/tip_model:predict
   ```

8. Access the model prediction at:
   ```
   http://localhost:8501/v1/models/tip_model
   ```
