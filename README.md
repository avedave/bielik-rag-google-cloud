# Bielik Squadron - Mission 2 - RAG based on Bielik model and Google Cloud

Sovereign and reliable AI - From company documents to an intelligent knowledge base based on the Bielik model and Google Cloud.

## About the project

This repository presents a complete, serverless Retrieval-Augmented Generation (RAG) solution deployed in Google Cloud. The main goal of the application is to provide an efficient and sovereign intelligent assistant capable of answering user questions based on a dedicated knowledge base (e.g., internal documents, regulations).

The basic architecture of the deployed solution is based on the following services and components:
- **LLM Language Model:** Sovereign Polish model [Bielik](https://ollama.com/SpeakLeash/bielik-4.5b-v3.0-instruct) characterized by a very good understanding of the Polish language and Polish cultural context. Running in the Cloud Run service, it is responsible for the final generation of a natural response for the user.
- **Embedding Model:** Efficient [EmbeddingGemma](https://deepmind.google/models/gemma/embeddinggemma/) model running in the Cloud Run service, used for quick conversion of text (user queries and target documents) into vector representation.
- **Vector Knowledge Base:** Scalable data warehouse [BigQuery](https://cloud.google.com/bigquery?hl=en) with the Vector Search mechanism providing vector search of semantically matched fragments from among millions of source documents.
- **Logic and application server:** Application written in Python (with the FastAPI framework), providing a Web UI graphical overlay and public API tying the platforms together.

Additionally, thanks to a simple graphical interface, the application allows for convenient comparison and empirical testing of the "raw" Bielik model relying only on itself in confrontation with the richer stream of answers of the more modern RAG supported by a dedicated own context.


## What does the code consist of?

The sample source code contained in this repository allows in particular to:

* Configure your own instance of the [Bielik](https://ollama.com/SpeakLeash/bielik-4.5b-v3.0-instruct) model based on the [Ollama](https://ollama.com/) engine

* Configure your own instance of the [EmbeddingGemma](https://deepmind.google/models/gemma/embeddinggemma/) embedding model based on [Ollama](https://ollama.com/)

* Run both of the above models on a serverless platform: [Cloud Run](https://cloud.google.com/run?hl=en)

* Configure a vector database in [BigQuery](https://cloud.google.com/bigquery?hl=en) along with special advanced searching [BigQuery Vector Search](https://docs.cloud.google.com/bigquery/docs/vector-search)

## 1. Preparing the Google Cloud project

1. Obtain **OnRamp** Cloud credit, or configure billing in your Google Cloud project

2. Go to **Google Cloud Console**: [console.cloud.google.com](https://console.cloud.google.com)

3. Create a new Google Cloud project and select it to be active
>[!TIP]
>You can check the availability of OnRamp credits by selecting from the menu on the left: Billing / Credits

4. Open Cloud Shell ([documentation](https://cloud.google.com/shell/docs))

5. Verify the account that is logged in to Cloud Shell
   ```bash
   gcloud auth list
   ```
>[!TIP]
>If the account is not logged in, or it is a different account from the one with access to your Google Cloud project, log in using the command: `gcloud auth login`

6. Confirm that the correct Google Cloud project is selected
   ```bash
   gcloud config get project
   ```
>[!TIP]
>If the project is incorrect, change it using the command: `gcloud config set project <YOUR_PROJECT_ID>`

>[!CAUTION]
>Do not confuse the project name with the project ID! They are not always the same.

7. Clone the repository with the sample code and go to the newly created directory
   ```bash
   git clone https://github.com/avedave/eskadra-bielik-misja2
   ```

8. Go to the directory with the source code
   ```bash
   cd eskadra-bielik-misja2
   ```

9. Start the editor in the directory with the source code
   ```bash
   cloudshell workspace .
   ```

## 2. Configuration of environmental variables and Google Cloud services

1. Analyze the script `setup_env.sh`

2. Reopen the Cloud Shell terminal

3. Run the script `setup_env.sh`
   ```bash
   source setup_env.sh
   ```
>[!IMPORTANT]
>If for some reason you have to restart the Cloud Shell terminal, remember to rerun the script `setup_env.sh` to load the environmental variables.

4. Enable the necessary services in the Google Cloud project
   ```bash
   gcloud services enable run.googleapis.com
   gcloud services enable cloudbuild.googleapis.com
   gcloud services enable artifactregistry.googleapis.com
   gcloud services enable bigquery.googleapis.com
   ```
5. Obtain permissions to invoke Cloud Run services
   ```bash
   gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=user:$(gcloud config get-value account) \
    --role='roles/run.invoker'
   ```  

## 3. Running the Bielik LLM model on Cloud Run

1. Analyze the script `llm/cloud_run.sh`

2. Run the script `llm/cloud_run.sh`
   ```bash
   cd llm
   ./cloud_run.sh
   ```
3. Check the status of the `bielik` service in Cloud Console - Cloud Run - Services

4. Analyze the file `llm/llm_test1.sh` and ask the first question to the Bielik model by running this script
   ```bash
   ./llm_test1.sh
   ```
5. Return to the main project directory
   ```bash
   cd ..
   ```

## 4. Running the EmbeddingGemma embedding model on Cloud Run

1. Analyze the script `embedding_model/cloud_run.sh`

2. Run the script `embedding_model/cloud_run.sh`
   ```bash
   cd embedding_model
   ./cloud_run.sh
   ```
3. Check the status of the `embedding-gemma` service in Cloud Console - Cloud Run - Services

4. Analyze the file `embedding_model/embedding_test1.sh` and generate the first test embeddings (vectors) for the sample text by running this script
   ```bash
   ./embedding_test1.sh
   ```
5. Return to the main project directory
   ```bash
   cd ..
   ```

## 5. Initialization of the vector database in BigQuery

The project uses BigQuery with the Vector Search function as a database with contextual knowledge.

1. Go to the `vector_store` directory
   ```bash
   cd vector_store
   ```

2. Install the required libraries (in the development environment)
   ```bash
   pip install google-cloud-bigquery
   ```

3. Run the initialization script, which will create the dataset and table in BigQuery
   ```bash
   python init_db.py
   ```

4. Return to the main project directory
   ```bash
   cd ..
   ```

## 6. Running the API (Orchestration) on Cloud Run

1. Analyze the FastAPI application code in the `orchestration` directory

2. Go to the `orchestration` directory
   ```bash
   cd orchestration
   ```

3. Run the script publishing the application on Cloud Run
   ```bash
   ./cloud_run.sh
   ```

4. After deployment, gcloud will print the URL of the `orchestration-api` service. Save it to an environmental variable
   ```bash
   export ORCHESTRATION_URL=$(gcloud run services describe orchestration-api --region $REGION --format="value(status.url)")
   ```

5. Return to the main directory
   ```bash
   cd ..
   ```

## 7. Testing the API - Data Ingestion and Search (RAG)

1. Populate the BigQuery database with sample data from the CSV file
   ```bash
   curl -X POST "$ORCHESTRATION_URL/ingest" \
        -F "file=@vector_store/hotel_rules.csv"
   ```

2. Check in Google Cloud Console -> BigQuery if the records appeared in the table `rag_dataset.hotel_rules` 
   *(The data indexing process to Vector Search may take a moment, however, text data is visible immediately).*

3. Execute a test query using RAG, asking about information from the uploaded rules
   
   Question about the frequency of pool chlorine measurement:
   ```bash
   curl -X POST "$ORCHESTRATION_URL/ask" \
        -H "Content-Type: application/json" \
        -d '{"query": "How often should the pool chlorine level be measured?"}'
   ```

   Question about breakfast serving time:
   ```bash
   curl -X POST "$ORCHESTRATION_URL/ask" \
        -H "Content-Type: application/json" \
        -d '{"query": "What time is breakfast served?"}'
   ```
   
   Question about parking:
   ```bash
   curl -X POST "$ORCHESTRATION_URL/ask" \
        -H "Content-Type: application/json" \
        -d '{"query": "How much does the hotel parking cost?"}'
   ```

## 8. Application Programming Interface (API)

The application provides a simple API created using the *FastAPI* framework, allowing not only for populating the knowledge base but also for asking questions.

The application defines the following paths in the file `orchestration/main.py`:

* `GET /` – serves the static file of the user interface (`index.html`).
* `POST /ingest` – accepts a CSV file and indexes the information contained in it as vectors in BigQuery (using the `EmbeddingGemma` embedding model).
* `POST /ask` – the main RAG endpoint: 
  - converts the query from text to vector,
  - semantically searches for the 3 most similar vector documents in the BigQuery table,
  - builds a prompt with the found context,
  - sends the combined prompt to the `Bielik` model and returns the final response along with the selected and used context.
* `POST /ask_direct` – serves as a comparative juxtaposition (baseline). It receives a query and sends it directly to the base `Bielik` model, completely bypassing RAG.

## 9. User Interface (Web UI)

In addition to the API interface, the application also provides a simple WWW overlay. The whole thing allows for convenient checking and comparing the operation of the base Bielik model with the Bielik model supported by RAG.

The user interface is implemented in a single, static file: `orchestration/static/index.html`. 

The script embedded in the HTML file sends two simultaneous requests to the endpoints `/ask` (RAG supported) and `/ask_direct` (directly to the `Bielik` model) and presents both model responses side by side to illustrate the differences. It also displays next to it exactly which fragments of BigQuery documents the model used in case of relying on additional RAG context.

> [!TIP]
> We strongly encourage you to experiment! Carefully review the source code of the files `orchestration/main.py` and `orchestration/static/index.html` to see how simply BigQuery vector search combines with an LLM model in Python and serves a simple graphic JavaScript overlay. Try also modifying the `main.py` file code to command Bielik to behave like a pirate or an IT expert in system instructions!

### Starting the interface

To open the graphical interface of the test application from the level of your project:

1. Display and click on the URL address of the `orchestration-api` service by running the following command in the terminal:
   ```bash
   echo $ORCHESTRATION_URL
   ```
2. After opening the published page in your web browser, enter any query in the dialog box (e.g. "Until what time is the pool open?") and click "Ask".
3. Compare the response stream displayed for the model's knowledge base alone (without additional context) with the richer RAG response generated based on knowledge from the BigQuery Vector Search.



