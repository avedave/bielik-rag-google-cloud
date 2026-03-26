import os
from google.cloud import bigquery
from google.api_core.exceptions import Conflict

# Read environment variables
PROJECT_ID = os.environ.get("PROJECT_ID")
DATASET_ID = os.environ.get("BIGQUERY_DATASET", "rag_dataset")
TABLE_ID = os.environ.get("BIGQUERY_TABLE", "hotel_rules")
REGION = os.environ.get("REGION", "europe-west1")

def init_db():
    if not PROJECT_ID:
        print("Error: Context variable PROJECT_ID is not set. Run first: source setup_env.sh")
        return

    client = bigquery.Client(project=PROJECT_ID)

    # 1. Create dataset
    dataset_ref = f"{PROJECT_ID}.{DATASET_ID}"
    dataset = bigquery.Dataset(dataset_ref)
    dataset.location = REGION

    try:
        dataset = client.create_dataset(dataset, timeout=30)  # Google Cloud API call
        print(f"Dataset created: {dataset_ref}")
    except Conflict:
        print(f"Dataset {dataset_ref} already exists.")
    except Exception as e:
        print(f"Error creating dataset: {e}")
        return

    # 2. Create table with schema for Vector Search
    table_ref = f"{dataset_ref}.{TABLE_ID}"
    
    schema = [
        bigquery.SchemaField("id", "STRING", mode="REQUIRED"),
        bigquery.SchemaField("content", "STRING", mode="REQUIRED"),
        bigquery.SchemaField("embedding", "FLOAT64", mode="REPEATED")
    ]
    
    table = bigquery.Table(table_ref, schema=schema)
    
    try:
        table = client.create_table(table)
        print(f"Table created: {table_ref}")
    except Conflict:
        print(f"Table {table_ref} already exists.")
    except Exception as e:
        print(f"Error creating table: {e}")

if __name__ == "__main__":
    init_db()
