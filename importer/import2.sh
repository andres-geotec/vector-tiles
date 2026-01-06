#!/usr/bin/env bash
export $(cat .env | xargs)

echo "\nImportando datos a la base de datos"
bash importer/postgis.sh ${1:-}.geojson

echo "\nImportando capas a geoserver"
bash importer/geoserver.sh ${1:-}
