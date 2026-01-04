#!/usr/bin/env bash
export $(cat .env | xargs)

echo "\nImportando datos a la base de datos"
sh importer/postgis.sh ${1:-}.geojson

echo "\nImportando capas a geoserver"
sh importer/geoserver.sh ${1:-}
