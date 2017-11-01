#!/usr/bin/env bash

if [ ! -e data.pbf ]; then
	wget -O data.pbf http://osm.ramuno.lt/lithuania.pbf
fi

./osm2pgsql -s -c -C 1024 -E 3857 --multi-geometry -S ./osm2pgsql.style -d osm -U postgres data.pbf
psql -d osm -U postgres < index.sql
psql -d osm -U postgres -c 'GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO osm;'
