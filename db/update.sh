#!/usr/bin/env bash

DATAFILE=${DATAFILE:=data.pbf}
DIRTY_FILE=dirty_tiles_`date +%s`
TILESTACHE_CONFIG_FILE=$(readlink -f ./../tiles.cfg)

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
./osm2pgsql --username postgres --database osm --style ./osm2pgsql.style --multi-geometry --number-processes 4 --slim --cache 100 --proj 3857 --expire-tiles 7-18 --append change.osc > /dev/null

if [ $? -ne 0 ]; then
	exit
fi

# remove outside objects
psql -d osm -U postgres < remove_outside_objects.sql

# atsiminti dienos kaladėles savaitgaliui (šeštadieniui)
cat dirty_tiles >> dirty_tiles_weekly

# update generalisation on Saturday
if [[ $(date +%u) -eq 6 ]] ; then
# NOTE: IŠJUNGTA, KOL SERVERIS NETURI PAKANKAMAI ATMINTIES APDOROTI
#  psql -d osm -U postgres < way_generalisation.sql
  echo "water generalisation" `date`
  psql -d osm -U osm < gen_water.sql
  echo "building generalisation" `date`
  psql -d osm -U osm < gen_building.sql
  echo "forest generalisation" `date`
  psql -d osm -U osm < gen_forest.sql
  echo "done" `date`

  # apdoroti visas per savaitę išpurvintas kaladėles
  sort -u dirty_tiles_weekly > dirty_tiles
  rm dirty_tiles_weekly
fi

./update_search.sh

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

    #grep -E "^(10|11|12|13|14)" dirty_tiles > generate_bicycle_$DIRTY_FILE
    #grep -E "^(10|11|12|13|14)" dirty_tiles > generate_craftbeer_$DIRTY_FILE

    echo "Refreshing poi materialized view " `date`
    psql -d osm -U postgres < update_mv.sql

    echo "OpenMap.lt delete expired " `date`
    tilestache-clean -c $TILESTACHE_CONFIG_FILE -l all -e pbf --tile-list delete_openmap_$DIRTY_FILE
    echo "OpenMap.lt generate expired 14 " `date`
    tilestache-seed -c $TILESTACHE_CONFIG_FILE -x -l all -e pbf --tile-list generate_openmap_14_$DIRTY_FILE
    echo "OpenMap.lt generate expired 13 " `date`
    tilestache-seed -c $TILESTACHE_CONFIG_FILE -x -l all -e pbf --tile-list generate_openmap_13_$DIRTY_FILE
    echo "OpenMap.lt generate expired 12 " `date`
    tilestache-seed -c $TILESTACHE_CONFIG_FILE -x -l all -e pbf --tile-list generate_openmap_12_$DIRTY_FILE
    echo "OpenMap.lt generate expired 11 " `date`
    tilestache-seed -c $TILESTACHE_CONFIG_FILE -x -l all -e pbf --tile-list generate_openmap_11_$DIRTY_FILE
    echo "OpenMap.lt generate expired 10 " `date`
    tilestache-seed -c $TILESTACHE_CONFIG_FILE -x -l all -e pbf --tile-list generate_openmap_10_$DIRTY_FILE
    echo "OpenMap.lt generate expired 9 " `date`
    tilestache-seed -c $TILESTACHE_CONFIG_FILE -x -l all -e pbf --tile-list generate_openmap_9_$DIRTY_FILE
    echo "OpenMap.lt generate expired 8 " `date`
    tilestache-seed -c $TILESTACHE_CONFIG_FILE -x -l all -e pbf --tile-list generate_openmap_8_$DIRTY_FILE
    echo "OpenMap.lt generate expired 7 " `date`
    tilestache-seed -c $TILESTACHE_CONFIG_FILE -x -l all -e pbf --tile-list generate_openmap_7_$DIRTY_FILE

    echo "Bicycle delete expired " `date`
    tilestache-clean -c $TILESTACHE_CONFIG_FILE -l bicycle -e pbf --tile-list dirty_tiles
    #echo "Bicycle generate expired " `date`
    #tilestache-seed -c $TILESTACHE_CONFIG_FILE -x -l bicycle -e pbf --tile-list generate_bicycle_$DIRTY_FILE

    echo "Craftbeer delete expired " `date`
    tilestache-clean -c $TILESTACHE_CONFIG_FILE -l craftbeer -e pbf --tile-list dirty_tiles
    #echo "Craftbeer generate expired " `date`
    #tilestache-seed -c $TILESTACHE_CONFIG_FILE -x -l craftbeer -e pbf --tile-list generate_craftbeer_$DIRTY_FILE

    echo "Detail delete expired " `date`
    tilestache-clean -c $TILESTACHE_CONFIG_FILE -l detail -e pbf --tile-list dirty_tiles

    echo "Topo delete expired " `date`
    tilestache-clean -c $TILESTACHE_CONFIG_FILE -l topo -e pbf --tile-list dirty_tiles

    echo "Done " `date`

    rm delete_openmap_$DIRTY_FILE
    rm generate_openmap_*_$DIRTY_FILE
    #rm generate_bicycle_$DIRTY_FILE
    #rm generate_craftbeer_$DIRTY_FILE
fi

echo "Update end: `date +%c`"

find ./log/ -type f -mtime +7 -name '*.log' -execdir rm -- '{}' +
