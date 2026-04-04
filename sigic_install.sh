#!/bin/bash
set -e

FLAVOR=${1:-default}
HTTPS_MODE=$2

if [ -z "$HTTPS_MODE" ]; then
  echo "Uso: ./sigic_install.sh <sabor> [http|https|externalhttps]"
  echo "El valor de <sabor> debe corresponder a un archivo JSON en sigic-modos/ (ej: default.json)"
  exit 1
fi

FLAVOR_FILE="sigic-mixins/$FLAVOR.json"

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

# =========================
# 🔹 convertir JSON a flags
# =========================

FLAGS=""

# boolean flags
for key in useoidc usefrontendadmin usefrontendapp enableiaproxy enableiadb enablelevantamientoproxy enablelevantamientodb; do
  val=$(jq -r ".$key" "$FLAVOR_FILE")
  if [ "$val" = "true" ]; then
    FLAGS="$FLAGS --$key"
  fi
done

# string flags
ENV_TYPE=$(jq -r '.env_type' "$FLAVOR_FILE")
HOSTNAME=$(jq -r '.hostname' "$FLAVOR_FILE")
EMAIL=$(jq -r '.email' "$FLAVOR_FILE")
OIDC_URL=$(jq -r '.oidc_provider_url' "$FLAVOR_FILE")
HOMEPATH=$(jq -r '.homepath' "$FLAVOR_FILE")

# =========================
# 🔹 ejecutar script real
# =========================

python3 create-envfile.py \
  --env_type="$ENV_TYPE" \
  --hostname="$HOSTNAME" \
  --email="$EMAIL" \
  --oidc_provider_url="$OIDC_URL" \
  --homepath="$HOMEPATH" \
  $FLAGS \
  $HTTPS_FLAG

# =========================
# 🔹 profiles
# =========================

PROFILES=$(jq -r '.profiles | join(",")' "$FLAVOR_FILE")

echo "🚀 Profiles: $PROFILES"

COMPOSE_PROFILES=$PROFILES docker compose up -d


# =========================
# 🔹 importar keycloak (si aplica)
# =========================

if echo "$PROFILES" | grep -q "oidc"; then
  echo "🔐 Detectado profile oidc → importando configuración de Keycloak..."

  # esperar a que keycloak esté listo
  echo "⏳ Esperando Keycloak..."

  echo "⏳ Esperando Keycloak..."
  sleep 30

  echo "🚀 Ejecutando import de clientes..."

  docker exec keycloak4sigic bash -c "/scripts/import-keycloak-clients.sh"

  echo "✅ Keycloak configurado"
fi