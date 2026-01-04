WS='datos'
STORE='postgis_store'
PG_PORT='5432'
CAPA=${1:-}

curl -u "$GS_ADMIN_USER:$GS_ADMIN_PASSWORD" -X POST \
  -H "Content-Type: application/xml" \
  -d "<workspace><name>${WS}</name></workspace>" \
  "${GS_URL}/rest/workspaces"

curl -u "$GS_ADMIN_USER:$GS_ADMIN_PASSWORD" \
  "${GS_URL}/rest/workspaces/${WS}.json"

curl -u "$GS_ADMIN_USER:$GS_ADMIN_PASSWORD" -X POST \
  -H "Content-Type: application/xml" \
  -d "
<dataStore>
  <name>${STORE}</name>
  <connectionParameters>
    <host>${PG_HOST}</host>
    <port>${PG_PORT}</port>
    <database>${PG_DATABASE}</database>
    <schema>${PG_SCHEMA}</schema>
    <user>${PG_USER}</user>
    <passwd>${PG_PASSWORD}</passwd>
    <dbtype>postgis</dbtype>
  </connectionParameters>
</dataStore>
" \
  "${GS_URL}/rest/workspaces/${WS}/datastores"

curl -u "$GS_ADMIN_USER:$GS_ADMIN_PASSWORD" \
  "${GS_URL}/rest/workspaces/${WS}/datastores/${STORE}.json"

curl -u "$GS_ADMIN_USER:$GS_ADMIN_PASSWORD" -X POST \
  -H "Content-type: application/xml" \
  "${GS_URL}/rest/workspaces/${WS}/datastores/${STORE}/featuretypes" \
  -d "
<featureType>
  <name>${CAPA}</name>
  <nativeName>${CAPA}</nativeName>
  <srs>EPSG:4326</srs>
</featureType>
"
