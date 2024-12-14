#!/bin/bash
set -x
CLIENT_ID=
CLIENT_SECRET=

PHONE_NUMBER=$1
MESSAGE=$2
LOG_FILE="sms.log"

log() {
  TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
  echo "[$TIMESTAMP] $1" >> "$LOG_FILE"
}

ACCESS_TOKEN=$(curl -s -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials" \
  -d "client_id=$CLIENT_ID" \
  -d "client_secret=$CLIENT_SECRET" \
  "https://api.orange.com/oauth/v3/token" | jq -r '.access_token')

if [ -z "$ACCESS_TOKEN" ]; then
  log "Erreur : Impossible d'obtenir le jeton d'accès."
  exit 1
fi

RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
        \"outboundSMSMessageRequest\": {
            \"address\": \"tel:+225$PHONE_NUMBER\",
            \"senderAddress\": \"tel:+2250000\",
            \"outboundSMSTextMessage\": {
                \"message\": \"$MESSAGE\"
            }
        }
    }" \
  "https://api.orange.com/smsmessaging/v1/outbound/tel%3A%2B2250000/requests")

echo "Réponse API : $RESPONSE"

if echo "$RESPONSE" | grep -q '"resourceURL"'; then
  log "SMS envoyé avec succès au numéro $PHONE_NUMBER."
else
  log "Échec de l'envoi du SMS."
fi
