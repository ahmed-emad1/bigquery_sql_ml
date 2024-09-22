-- Creating external table referring to gcs path
CREATE OR REPLACE EXTERNAL TABLE `terraform-demo-435114.demo_dataset.external_yellow_trip_data`
OPTIONS (
  format = 'CSV',
  uris = ['gs://nyc-tl-data/trip data/yellow_tripdata_2019-*.csv', 'gs://nyc-tl-data/trip data/yellow_tripdata_2020-*.csv']
);

-- Check yello trip data
SELECT * FROM terraform-demo-435114.demo_dataset.external_yellow_trip_data limit 10;

-- Create a non partitioned table from external table
CREATE OR REPLACE TABLE terraform-demo-435114.demo_dataset.yellow_trip_data_non_partitoned AS
SELECT * FROM terraform-demo-435114.demo_dataset.external_yellow_trip_data;


-- Create a partitioned table from external table
CREATE OR REPLACE TABLE terraform-demo-435114.demo_dataset.yellow_trip_data_partitoned
PARTITION BY
  DATE(tpep_pickup_datetime) AS
SELECT * FROM terraform-demo-435114.demo_dataset.external_yellow_trip_data;

-- Impact of partition
-- Scanning 1.6GB of data
SELECT DISTINCT(VendorID)
FROM terraform-demo-435114.demo_dataset.yellow_trip_data_non_partitoned
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2019-06-30';

-- Scanning ~106 MB of DATA
SELECT DISTINCT(VendorID)
FROM terraform-demo-435114.demo_dataset.yellow_trip_data_partitoned
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2019-06-30';

-- Let's look into the partitons
SELECT table_name, partition_id, total_rows
FROM `nytaxi.INFORMATION_SCHEMA.PARTITIONS`
WHERE table_name = 'yellow_trip_data_partitoned'
ORDER BY total_rows DESC;

-- Creating a partition and cluster table
CREATE OR REPLACE TABLE terraform-demo-435114.demo_dataset.yellow_trip_data_partitoned_clustered
PARTITION BY DATE(tpep_pickup_datetime)
CLUSTER BY VendorID AS
SELECT * FROM terraform-demo-435114.demo_dataset.external_yellow_trip_data;

-- Query scans 1.1 GB
SELECT count(*) as trips
FROM terraform-demo-435114.demo_dataset.yellow_trip_data_partitoned
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2020-12-31'
  AND VendorID=1;

-- Query scans 864.5 MB
SELECT count(*) as trips
FROM terraform-demo-435114.demo_dataset.yellow_trip_data_partitoned_clustered
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2020-12-31'
  AND VendorID=1;
