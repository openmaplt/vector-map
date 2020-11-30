#!/usr/bin/env bash
set -xeuo pipefail

if [ ! -e data.pbf ]; then
	wget -O data.pbf http://download.geofabrik.de/europe/lithuania-latest.osm.pbf
fi

# load data
docker-compose exec -T db bash -xeuo pipefail <<-EOF
export PGPASSWORD=osm

if ! command -v osm2pgsql > /dev/null; then
    apt-get update
    apt-get install -y osm2pgsql jq curl
fi

# aktyvuojame postgis_sfcgal; jei neaktyvuojamas, neranda funkcijų
psql osm -U osm -c 'CREATE EXTENSION IF NOT EXISTS postgis_sfcgal;'

osm2pgsql \
    -s -c -C 512 --multi-geometry \
    -S /src/db/osm2pgsql.style \
    -d osm -U osm \
    /src/data.pbf
EOF

# dbfunc yra masyvas (array) iš visų db/func/*.sql failų
dbfunc=(db/func/*.sql)
# dbfuncfiles yra dbfunc failai su '-f /src/' prefix'u.
# atskirus failus yra geriau paduoti postgresql, nei viską cat'inti,
# nes, jei įvyksta klaida, psql gali pasakyti failo pavadinimą
# ir eilutės numerį, kur įvyko klaida.
dbfuncfiles=("${dbfunc[@]/#/-f /src/}")
# shellcheck disable=SC2068
docker-compose exec db psql osm -U osm \
    -f /src/db/index.sql \
    ${dbfuncfiles[@]} \
    -f /src/es/agg-linear-objects.sql \
    -f /src/db/tables/table_poi.sql \
    -f /src/db/tables/table_gen_ways.sql \
    -f /src/db/gen_way.sql \
    -f /src/db/gen_water.sql \
    -f /src/db/gen_building.sql \
    -f /src/db/gen_forest.sql \
    -f /src/db/gen_protected.sql \
    -f /src/data/coastline/coastline.sql

docker-compose exec db bash -xeuo pipefail <<-EOF
/src/es/db2es
/src/es/db2es-test
EOF

docker-compose exec -T db /src/db/upiu_baseinai/go.sh
