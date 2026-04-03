#!/bin/bash
set -e

REALM=sigic

FILES=(
  keycloak-client-sigic-admin.json
  keycloak-client-sigic-app.json
  keycloak-client-sigic-geonode.json
)

for FILE in "${FILES[@]}"; do
  PATH_JSON="/opt/keycloak/data/import/$FILE"

  CLIENT_ID=$(cat $PATH_JSON | grep '"clientId"' | head -1 | sed -E 's/.*"clientId": *"([^"]+)".*/\1/')

  CID=$(/opt/keycloak/bin/kcadm.sh get clients -r $REALM -q clientId=$CLIENT_ID --fields id --format csv | tail -n 1 | tr -d '"')

  if [ -z "$CID" ]; then
    echo "Creating $CLIENT_ID"
    /opt/keycloak/bin/kcadm.sh create clients -r $REALM -f $PATH_JSON
  else
    echo "Updating $CLIENT_ID"
    /opt/keycloak/bin/kcadm.sh update clients/$CID -r $REALM -f $PATH_JSON
  fi

done