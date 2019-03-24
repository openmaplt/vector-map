#!/usr/bin/env bash
DATAFILE=${DATAFILE:=data.pbf}
DIRTY_FILE=dirty_tiles_`date +%s`
TEGOLA_CONFIG_FILE=$(readlink -f ./../config.toml)
LOCK_FILE=/tmp/openmap_update

if [ -f $LOCK_FILE ]; then
  echo "Update already running"
  exit
else
  touch $LOCK_FILE
fi

echo "----------"
echo "Update started: `date +%c`"

# download data
if [ ! -e $DATAFILE ]; then
	wget -O $DATAFILE http://download.geofabrik.de/europe/lithuania-latest.osm.pbf
fi

# update
rm change.osc.gz
./osmupdate $DATAFILE change.osc.gz
if [ ! -s change.osc.gz ]; then
	echo "Failed to update data"
	exit
fi

# apply & clip
./osmconvert $DATAFILE change.osc.gz -B=lithuania.poly --complete-ways --complex-ways --out-o5m > temp.o5m
./osmconvert $DATAFILE temp.o5m --diff > change.osc

#apply diff
rm dirty_tiles
./osm2pgsql --username postgres --database osm --style ./osm2pgsql.style -x --multi-geometry --number-processes 4 --slim --cache 100 --proj 3857 --expire-tiles 7-18 --append change.osc > /dev/null

if [ $? -ne 0 ]; then
	exit
fi

# remove outside objects
psql -d osm -U postgres < remove_outside_objects.sql

# atsiminti dienos kaladėles savaitgaliui (šeštadieniui)
cat dirty_tiles >> dirty_tiles_weekly

# update generalisation on Saturday
if [[ $(date +%u) -eq 56 ]] ; then
# NOTE: IŠJUNGTA, KOL SERVERIS NETURI PAKANKAMAI ATMINTIES APDOROTI
#  psql -d osm -U postgres < way_generalisation.sql
  echo "water generalisation" `date`
  psql -d osm -U osm < gen_water.sql
  echo "building generalisation" `date`
  psql -d osm -U osm < gen_building.sql
  echo "forest generalisation" `date`
  psql -d osm -U osm < gen_forest.sql
  echo "protected area generalisation" `date`
  psql -d osm -U osm < gen_protected.sql
  echo "done" `date`

  # apdoroti visas per savaitę išpurvintas kaladėles
  sort -u dirty_tiles_weekly > dirty_tiles
  rm dirty_tiles_weekly
fi

./osmconvert temp.o5m --out-pbf > temp.pbf
mv temp.pbf data.pbf

if [ $? -ne 0 ]; then
	exit
fi

rm temp.o5m
md5sum $DATAFILE > $DATAFILE.md5

# render expired
if [ -s dirty_tiles ]; then
    echo "Preparing tile lists " `date`
    grep -E "^(15|16|17|18)" dirty_tiles > delete_openmap_$DIRTY_FILE
    grep -E "^(14)" dirty_tiles > generate_openmap_14_$DIRTY_FILE
    grep -E "^(13)" dirty_tiles > generate_openmap_13_$DIRTY_FILE
    grep -E "^(12)" dirty_tiles > generate_openmap_12_$DIRTY_FILE
    grep -E "^(11)" dirty_tiles > generate_openmap_11_$DIRTY_FILE
    grep -E "^(10)" dirty_tiles > generate_openmap_10_$DIRTY_FILE
    grep -E "^(9)"  dirty_tiles > generate_openmap_9_$DIRTY_FILE
    grep -E "^(8)"  dirty_tiles > generate_openmap_8_$DIRTY_FILE
    grep -E "^(7)"  dirty_tiles > generate_openmap_7_$DIRTY_FILE

    grep -E "^(10|11|12|13|14)" dirty_tiles > generate_bicycle_$DIRTY_FILE
    grep -E "^(10|11|12|13|14)" dirty_tiles > generate_craftbeer_$DIRTY_FILE

    echo "Refreshing materialized views " `date`
    psql -d osm -U postgres < update_mv.sql
    echo "Refreshing waterbody labels " `date`
    psql -d osm -U postgres < update_water_labels.sql

    echo "OpenMap.lt delete expired tiles large scale tiles in layer 'all' " `date`
    ../tegola cache purge --config $TEGOLA_CONFIG_FILE --map="all" tile-list delete_openmap_$DIRTY_FILE

    echo "OpenMap.lt regenerate expired 14 " `date`
    ../tegola cache seed --config $TEGOLA_CONFIG_FILE --map="all" tile-list generate_openmap_14_$DIRTY_FILE --overwrite --concurrency 3
    echo "OpenMap.lt regenerate expired 13 " `date`
    ../tegola cache seed --config $TEGOLA_CONFIG_FILE --map="all" tile-list generate_openmap_13_$DIRTY_FILE --overwrite --concurrency 3
    echo "OpenMap.lt regenerate expired 12 " `date`
    ../tegola cache seed --config $TEGOLA_CONFIG_FILE --map="all" tile-list generate_openmap_12_$DIRTY_FILE --overwrite --concurrency 3
    echo "OpenMap.lt regenerate expired 11 " `date`
    ../tegola cache seed --config $TEGOLA_CONFIG_FILE --map="all" tile-list generate_openmap_11_$DIRTY_FILE --overwrite --concurrency 3
    echo "OpenMap.lt regenerate expired 10 " `date`
    ../tegola cache seed --config $TEGOLA_CONFIG_FILE --map="all" tile-list generate_openmap_10_$DIRTY_FILE --overwrite --concurrency 3
    echo "OpenMap.lt regenerate expired 9 " `date`
    ../tegola cache seed --config $TEGOLA_CONFIG_FILE --map="all" tile-list generate_openmap_9_$DIRTY_FILE --overwrite --concurrency 3
    echo "OpenMap.lt regenerate expired 8 " `date`
    ../tegola cache seed --config $TEGOLA_CONFIG_FILE --map="all" tile-list generate_openmap_8_$DIRTY_FILE --overwrite --concurrency 3
    echo "OpenMap.lt regenerate expired 7 " `date`
    ../tegola cache seed --config $TEGOLA_CONFIG_FILE --map="all" tile-list generate_openmap_7_$DIRTY_FILE --overwrite --concurrency 3

    ../tegola cache purge --config $TEGOLA_CONFIG_FILE --map="detail" tile-list dirty_tiles
    ../tegola cache purge --config $TEGOLA_CONFIG_FILE --map="topo"   tile-list dirty_tiles

    echo "Bicycle regenerate expired " `date`
    ../tegola cache purge --config $TEGOLA_CONFIG_FILE --map="bicycle" tile-list dirty_tiles
    ../tegola cache seed  --config $TEGOLA_CONFIG_FILE --map="bicycle" tile-list generate_bicycle_$DIRTY_FILE --overwrite --concurrency 3

    echo "Craftbeer generate expired " `date`
    ../tegola cache purge --config $TEGOLA_CONFIG_FILE --map="craftbeer" tile-list dirty_tiles
    ../tegola cache seed  --config $TEGOLA_CONFIG_FILE --map="craftbeer" tile-list generate_craftbeer_$DIRTY_FILE --overwrite --concurrency 3

    echo "Done " `date`

    rm delete_openmap_$DIRTY_FILE
    rm generate_openmap_*_$DIRTY_FILE
    rm generate_bicycle_$DIRTY_FILE
    rm generate_craftbeer_$DIRTY_FILE
fi

echo "Update end: `date +%c`"

find ./log/ -type f -mtime +7 -name '*.log' -execdir rm -- '{}' +

rm $LOCK_FILE
