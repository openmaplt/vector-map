#!/usr/bin/env bash
DATAFILE=${DATAFILE:=data.pbf}
DIRTY_FILE=dirty_tiles_`date +%s`
TEGOLA_CONFIG_FILE=$(readlink -f ./../config.toml)
TEGOLA_SEED="tegola cache seed --config $TEGOLA_CONFIG_FILE --overwrite --concurrency 3"
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
  rm $LOCK_FILE
  exit
fi

# apply & clip
./osmconvert $DATAFILE change.osc.gz -B=lithuania.poly --complete-ways --complex-ways --out-o5m > temp.o5m
./osmconvert $DATAFILE temp.o5m --diff > change.osc

#apply diff
rm dirty_tiles
osm2pgsql --username osm --database osm --style ./osm2pgsql.style -x --multi-geometry --number-processes 4 --slim --cache 100 --proj 3857 --expire-tiles 7-18 --append change.osc > /dev/null

if [ $? -ne 0 ]; then
  rm $LOCK_FILE
  exit
fi

# remove outside objects
psql -d osm -U osm < remove_outside_objects.sql

echo "Refreshing materialized views " `date`
psql -d osm -U osm < update_mv.sql
echo "Refreshing waterbody labels " `date`
psql -d osm -U osm < update_water_labels.sql

# atsiminti dienos kaladėles savaitgaliui (šeštadieniui)
cat dirty_tiles >> dirty_tiles_weekly

# update generalisation on Saturday
if [[ $(date +%u) -eq 6 ]] ; then
  echo "way generalisation" `date`
  psql -d osm -U osm < gen_way.sql
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
  rm $LOCK_FILE
  exit
fi

rm temp.o5m
md5sum $DATAFILE > $DATAFILE.md5

# render expired
if [ -s dirty_tiles ]; then
    echo "Preparing tile lists " `date`

    grep -E "^(10|11|12|13|14)" dirty_tiles > generate_bicycle_$DIRTY_FILE

    echo "OpenMap.lt delete expired large scale tiles in layer 'all' " `date`
    rm -rf /var/cache/tegola/all/1[6-8] || true

    tegola cache purge --config $TEGOLA_CONFIG_FILE --map="detail"    tile-list dirty_tiles > /dev/null
    tegola cache purge --config $TEGOLA_CONFIG_FILE --map="topo"      tile-list dirty_tiles > /dev/null
    tegola cache purge --config $TEGOLA_CONFIG_FILE --map="river"     tile-list dirty_tiles > /dev/null
    tegola cache purge --config $TEGOLA_CONFIG_FILE --map="craftbeer" tile-list dirty_tiles > /dev/null
    tegola cache purge --config $TEGOLA_CONFIG_FILE --map="speed"     tile-list dirty_tiles > /dev/null

    echo "Bicycle regenerate expired " `date`
    tegola cache purge --config $TEGOLA_CONFIG_FILE --map="bicycle" tile-list dirty_tiles > /dev/null
    $TEGOLA_SEED --map="bicycle" tile-list generate_bicycle_$DIRTY_FILE > /dev/null

    for ZOOM in $(seq 15 -1 7); do
        echo "OpenMap.lt regenerate expired $ZOOM " `date`
        grep -E "^$ZOOM/" dirty_tiles > generate_openmap_${ZOOM}_$DIRTY_FILE
        $TEGOLA_SEED --map="all" tile-list generate_openmap_${ZOOM}_$DIRTY_FILE > /dev/null
    done
    rm generate_openmap_*_$DIRTY_FILE

    echo "Done " `date`

    rm generate_bicycle_$DIRTY_FILE
fi

echo "Update end: `date +%c`"

find ./log/ -type f -mtime +7 -name '*.log' -execdir rm -- '{}' +

rm $LOCK_FILE
