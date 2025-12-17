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
PG_DSN="host=${PGHOST} port=${PGPORT} dbname=${PGDATABASE} user=${PGUSER} password=${PGPASSWORD}"

# Opciones:
# -nln: nombre capa destino
# -lco GEOMETRY_NAME=geom: columna geom
# -nlt PROMOTE_TO_MULTI: asegura multi*
# -t_srs: reproyecta a SRID destino
ogr2ogr \
  -f "PostgreSQL" "PG:${PG_DSN}" \
  "${SHP_PATH}" \
  -nln "${PGSCHEMA}.${GDRIVE_SHAPE_NAME}" \
  -lco GEOMETRY_NAME=the_geom \
  -lco FID=id \
  -nlt PROMOTE_TO_MULTI \
  -t_srs "EPSG:4326" \
  -overwrite

echo "==> Listo. Verificando conteo..."
psql "postgresql://${PGUSER}:${PGPASSWORD}@${PGHOST}:${PGPORT}/${PGDATABASE}" \
  -c "SELECT COUNT(*) AS rows FROM ${PGSCHEMA}.${GDRIVE_SHAPE_NAME};"

echo "==> Import terminado OK."
