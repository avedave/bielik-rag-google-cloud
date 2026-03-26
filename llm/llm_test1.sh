#!/bin/bash

# get the LLM service URL
export LLM_SERVICE_URL=$(gcloud run services describe $LLM_SERVICE --region $REGION --format="value(status.url)")

# get the authorization token
export ID_TOKEN=$(gcloud auth print-identity-token)

curl -X POST "$LLM_SERVICE_URL/api/chat" \
    -H "Authorization: Bearer $ID_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "model": "SpeakLeash/bielik-4.5b-v3.0-instruct:Q8_0",
        "messages": [{ "role": "user", "content": "How often should the pool chlorine level be measured?" }],
        "stream": false
    }'
