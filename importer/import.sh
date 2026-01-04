#!/usr/bin/env bash
set -euo pipefail

: "${GDRIVE_FOLDER_ID:?Falta GDRIVE_FOLDER_ID}"
# : "${TABLE_NAME:=public.capa_importada}"
# : "${TARGET_SRID:=4326}"

echo "==> Descargando desde Google Drive (ID=${GDRIVE_FOLDER_ID})..."
mkdir -p /work/data
cd /work/data

gdown --folder $GDRIVE_FOLDER_ID

echo '==> Descargado'

SHP_PATH="${GDRIVE_FOLDER_NAME}/${GDRIVE_SHAPE_NAME}.shp"
PG_DSN="host=${PG_HOST} port=${PG_PORT} dbname=${PG_DATABASE} user=${PG_USER} password=${PG_PASSWORD}"

# Opciones:
# -nln: nombre capa destino
# -lco GEOMETRY_NAME=geom: columna geom
# -nlt PROMOTE_TO_MULTI: asegura multi*
# -t_srs: reproyecta a SRID destino
ogr2ogr \
  -f "PostgreSQL" "PG:${PG_DSN}" \
  "${SHP_PATH}" \
  -nln "${PG_SCHEMA}.${GDRIVE_SHAPE_NAME}" \
  -lco GEOMETRY_NAME=the_geom \
  -lco FID=id \
  -lco PRECISION=NO \
  -nlt PROMOTE_TO_MULTI \
  -t_srs "EPSG:4326" \
  -overwrite

echo "==> Listo. Verificando conteo..."
psql "postgresql://${PG_USER}:${PG_PASSWORD}@${PG_HOST}:${PG_PORT}/${PG_DATABASE}" \
  -c "SELECT COUNT(*) AS rows FROM ${PG_SCHEMA}.${GDRIVE_SHAPE_NAME};"

echo "==> Import terminado OK."
