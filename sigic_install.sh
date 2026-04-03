#!/bin/bash
set -e

FLAVOR=$1
HTTPS_MODE=$2

if [ -z "$FLAVOR" ]; then
  echo "Uso: ./run-flavor.sh <flavor> [http|https|externalhttps]"
  exit 1
fi

FLAVOR_FILE="flavors/$FLAVOR.json"

if [ ! -f "$FLAVOR_FILE" ]; then
  echo "No existe flavor: $FLAVOR_FILE"
  exit 1
fi

echo "🔥 Usando flavor: $FLAVOR"

# =========================
# 🔹 HTTPS runtime (definitivo)
# =========================

HTTPS_FLAG=""

case "$HTTPS_MODE" in
  https)
    HTTPS_FLAG="--https"
    ;;
  externalhttps)
    HTTPS_FLAG="--externalhttps"
    ;;
  http|"")
    HTTPS_FLAG=""
    ;;
  *)
    echo "Modo HTTPS inválido: $HTTPS_MODE"
    echo "Usa: http | https | externalhttps"
    exit 1
    ;;
esac

echo "🌐 Modo: ${HTTPS_MODE:-http}"

# =========================
# 🔹 generar .env + jsons
# =========================

python3 create-envfile.py \
  -f "$FLAVOR_FILE" \
  $HTTPS_FLAG

# =========================
# 🔹 profiles
# =========================

PROFILES=$(jq -r '.profiles | join(",")' "$FLAVOR_FILE")

echo "🚀 Profiles: $PROFILES"

COMPOSE_PROFILES=$PROFILES docker compose up -d