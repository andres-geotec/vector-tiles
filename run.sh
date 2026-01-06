docker compose build --no-cache; docker compose stop; docker compose up -d;

sh importer/import2.sh ${1:-}

docker restart martin
