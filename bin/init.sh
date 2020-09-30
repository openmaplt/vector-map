#!/usr/bin/env bash

if [ ! -e data.pbf ]; then
	wget -O data.pbf http://download.geofabrik.de/europe/lithuania-latest.osm.pbf
fi

CONTAINER_DB=`docker-compose ps -q db`
# install shp2pgsql
docker exec $CONTAINER_DB sh -c 'apt update -qy && apt install -qy postgis'

# load data
docker run --rm -it -w /tmp/src -v `pwd`:/tmp/src --network "container:$CONTAINER_DB" -e PGPASSWORD=osm openmap/osm2pgsql:latest osm2pgsql -s -c -C 512 --multi-geometry -S db/osm2pgsql.style -d osm -U osm -H db data.pbf
docker exec -u postgres $CONTAINER_DB sh -c 'psql osm -f /src/db/index.sql'
docker exec -u postgres $CONTAINER_DB sh -c 'cat /src/db/func/*.sql | psql osm -f -'

docker exec -u postgres $CONTAINER_DB sh -c 'psql osm -f /src/db/tables/table_poi.sql'
docker exec -u postgres $CONTAINER_DB sh -c 'psql osm -f /src/db/tables/table_gen_ways.sql'

docker exec -u postgres $CONTAINER_DB sh -c 'psql osm -f /src/db/gen_way.sql'
docker exec -u postgres $CONTAINER_DB sh -c 'psql osm -f /src/db/gen_water.sql'
docker exec -u postgres $CONTAINER_DB sh -c 'psql osm -f /src/db/gen_building.sql'
docker exec -u postgres $CONTAINER_DB sh -c 'psql osm -f /src/db/gen_forest.sql'
docker exec -u postgres $CONTAINER_DB sh -c 'psql osm -f /src/db/gen_protected.sql'

docker exec -u postgres $CONTAINER_DB sh -c 'bzip2 -cd /src/data/coastline/coastline.sql.bz2 | psql osm'
docker exec -u postgres -w /src/db/upiu_baseinai $CONTAINER_DB ./go.sh
