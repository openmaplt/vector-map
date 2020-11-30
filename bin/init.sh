#!/usr/bin/env bash
set -euo pipefail

usage() {
    >&2 "Usage: $(basename "$0") [CLIP]"
    >&2 echo
    >&2 echo "Downloads data and initializes the databases"
    >&2 echo "[CLIP] is either 'small' or 'medium'; it will clip dataset for testing"
}

if [ ! -e lithuania-latest.osm.pbf ]; then
	wget http://download.geofabrik.de/europe/lithuania-latest.osm.pbf
fi

case ${1:-} in
    small) clip=24.7,56.15,24.8,54.25;; # Biržai
    medium) clip=25.05,54.55,25.5,54.8;; # Vilnius
    "") clip="";;
    *) usage; exit 1;;
esac

set -x

rm -f data.pbf
if [[ $clip != "" ]]; then
    osmium extract -b "$clip" lithuania-latest.osm.pbf -o data.pbf
else
    ln -s lithuania-latest.osm.pbf data.pbf
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

/src/es/db2es
/src/es/db2es-test
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
    -f /src/db/tables/table_poi.sql \
    -f /src/db/tables/table_gen_ways.sql \
    -f /src/db/gen_way.sql \
    -f /src/db/gen_water.sql \
    -f /src/db/gen_building.sql \
    -f /src/db/gen_forest.sql \
    -f /src/db/gen_protected.sql \
    -f /src/data/coastline/coastline.sql

docker-compose exec -T db /src/db/upiu_baseinai/go.sh
