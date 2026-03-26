#!/bin/bash

# Service name for Cloud Run
export ORCHESTRATION_SERVICE="orchestration-api"

# Ensure environment variables are set to inject into the service
if [ -z "$REGION" ] || [ -z "$PROJECT_ID" ] || [ -z "$EMBEDDING_SERVICE" ] || [ -z "$LLM_SERVICE" ]; then
    echo "Missing required environment variables. Run 'source ../setup_env.sh' in the main directory."
    exit 1
fi

# Get URLs of model services (or rely on built-in Cloud Run / Cloud DNS routing if in same network)
export EMBEDDING_URL=$(gcloud run services describe $EMBEDDING_SERVICE --region $REGION --format 'value(status.url)')
export LLM_URL=$(gcloud run services describe $LLM_SERVICE --region $REGION --format 'value(status.url)')

if [ -z "$EMBEDDING_URL" ] || [ -z "$LLM_URL" ]; then
    echo "Failed to retrieve service URLs. Make sure models are deployed."
    exit 1
fi

gcloud run deploy $ORCHESTRATION_SERVICE \
  --source . \
  --region $REGION \
  --allow-unauthenticated \
  --set-env-vars PROJECT_ID=$PROJECT_ID,BIGQUERY_DATASET=$BIGQUERY_DATASET,BIGQUERY_TABLE=$BIGQUERY_TABLE,REGION=$REGION,EMBEDDING_URL=$EMBEDDING_URL,LLM_URL=$LLM_URL \
  --max-instances 2 \
  --labels dev-tutorial=dos-codelab-bielik-rag
