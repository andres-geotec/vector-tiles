#!/usr/bin/env bash
set -euo pipefail

PG_HOST='localhost'

INPUT="./data/${1:-}"
TABLE="${2:-}"
TARGET_EPSG="${3:-}"  # opcional

CONN_STR="PG:host=${PG_HOST} port=${PG_PORT} dbname=${PG_DATABASE} user=${PG_USER} password=${PG_PASSWORD}"

EXT="${INPUT##*.}"
EXT_LOWER="$(echo "$EXT" | tr '[:upper:]' '[:lower:]')"

# # Para .shp: OGR espera el path al .shp
# # Para .geojson: igual
# # Para .gpkg: puede traer múltiples capas: por defecto tomamos la primera capa si no se especifica.
# LAYER_ARG=()

# if [[ "$EXT_LOWER" == "gpkg" ]]; then
#   # Si el usuario define GPKG_LAYER, se usa esa capa. Si no, se toma la primera.
#   if [[ -n "${GPKG_LAYER:-}" ]]; then
#     LAYER_ARG=(-nln "$TABLE" "$INPUT" "$GPKG_LAYER")
#   else
#     # Descubre la primera capa
#     FIRST_LAYER="$(ogrinfo -ro -so "$INPUT" 2>/dev/null | awk -F': ' '/^[0-9]+: /{print $2; exit}')"
#     if [[ -z "$FIRST_LAYER" ]]; then
#       echo "Error: no pude detectar capas dentro del GPKG."
#       exit 1
#     fi
#     echo "GPKG detectado. Usando primera capa: $FIRST_LAYER"
#     LAYER_ARG=(-nln "$TABLE" "$INPUT" "$FIRST_LAYER")
#   fi
# else
#   LAYER_ARG=(-nln "$TABLE" "$INPUT")
# fi

LAYER_ARG=(-nln "$TABLE" "$INPUT")

# Opciones comunes:
# -nlt PROMOTE_TO_MULTI: homogeniza a MULTI* (útil para evitar conflictos de tipos)
# -lco GEOMETRY_NAME=geom: nombre de la columna geom
# -lco FID=id: nombre de columna id
# -lco SPATIAL_INDEX=GIST: crea índice espacial
# -overwrite: reemplaza la tabla si existe
# -progress: barra de progreso
OGR_OPTS=(
  -f "PostgreSQL" "$CONN_STR"
  "${LAYER_ARG[@]}"
  -lco GEOMETRY_NAME="${PG_GEOMETRY_NAME}"
  -lco FID=id
  -lco SPATIAL_INDEX=GIST
  -nlt PROMOTE_TO_MULTI
  -overwrite
  -progress
)

# Si se pide reproyección:
# Nota: ogr2ogr necesita saber el SRS de origen para reproyectar bien.
# Si tu archivo no trae CRS, define SOURCE_EPSG=XXXX.
if [[ -n "$TARGET_EPSG" ]]; then
  if [[ -n "${SOURCE_EPSG:-}" ]]; then
    OGR_OPTS+=(-s_srs "EPSG:${SOURCE_EPSG}")
  fi
  OGR_OPTS+=(-t_srs "EPSG:${TARGET_EPSG}")
fi

echo "Importando '$INPUT' -> ${PG_DATABASE}.${TABLE} (host=$PG_HOST port=$PG_PORT user=$PG_USER)"
ogr2ogr "${OGR_OPTS[@]}"
