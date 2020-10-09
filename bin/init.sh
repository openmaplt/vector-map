#!/usr/bin/env bash
set -euo pipefail

if [ ! -e data.pbf ]; then
	wget -O data.pbf http://download.geofabrik.de/europe/lithuania-latest.osm.pbf
fi

CONTAINER_DB=$(docker-compose ps -q db)
# install shp2pgsql
docker exec "$CONTAINER_DB" sh -c 'apt update -qy && apt install -qy postgis'

# load data
docker run --rm -it \
    -w /tmp/src \
    -v "$(pwd):/tmp/src" \
    --network "container:$CONTAINER_DB" \
    -e PGPASSWORD=osm openmap/osm2pgsql:latest \
    osm2pgsql \
        -s -c -C 512 --multi-geometry \
        -S db/osm2pgsql.style \
        -d osm -U osm \
        -H db \
        data.pbf

# dbfunc yra masyvas (array) iš visų db/func/*.sql failų
dbfunc=(db/func/*.sql)
# dbfuncfiles yra dbfunc failai su '-f' prefix'u.
# atskirus failus yra geriau paduoti postgresql, nei viską cat'inti,
# nes, jei įvyksta klaida, psql gali pasakyti failo pavadinimą
# ir eilutės numerį, kur įvyko klaida.
dbfuncfiles=("${dbfunc[@]/#/-f }")
docker exec -w /src "$CONTAINER_DB" psql osm -U osm \
    -f db/index.sql \
    "${dbfuncfiles[@]}" \
    -f db/tables/table_poi.sql \
    -f db/tables/table_gen_ways.sql \
    -f db/gen_way.sql \
    -f db/gen_water.sql \
    -f db/gen_building.sql \
    -f db/gen_forest.sql \
    -f db/gen_protected.sql

docker exec -w /src "$CONTAINER_DB" bash <<-EOF
set -euo pipefail
bzip2 -cd data/coastline/coastline.sql.bz2 | psql -U osm osm
db/upiu_baseinai/go.sh
EOF
