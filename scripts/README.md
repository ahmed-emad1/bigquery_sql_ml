load files directly to GCS, without Airflow. Downloads csv files from https://nyc-tlc.s3.amazonaws.com/trip+data/ and uploads them to your Cloud Storage Account as parquet files.

1. `pip install pandas pyarrow google-cloud-storage` using 
2. Run: python web_to_gcs.py

however in the case that your device can't handle the script I have created a dag file to upload the data as my device had issues with running the script which can be found [here](https://github.com/ahmed-emad1/airflow-bigquery-docker/blob/main/dags/data_gcs_upload_dag.py)