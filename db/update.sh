#!/usr/bin/env bash

DATAFILE=${DATAFILE:=data.pbf}
DIRTY_FILE=dirty_tiles_`date +%s`
TILESTACHE_CONFIG_FILE=$(readlink -f ./../tiles.cfg)

echo "----------"
echo "Update started: `date +%c`"

# download data
if [ ! -e $DATAFILE ]; then
	wget -O $DATAFILE http://osm.ramuno.lt/lithuania.pbf
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

./osmconvert temp.o5m --out-pbf > temp.pbf
mv temp.pbf data.pbf

if [ $? -ne 0 ]; then
	exit
fi

rm temp.o5m
md5sum $DATAFILE > $DATAFILE.md5

# render expired
if [ -s dirty_tiles ]; then
         
	grep -E "^(16|17|18)" dirty_tiles > delete_openmap_$DIRTY_FILE
	grep -E -v "^(16|17|18)" dirty_tiles > generate_openmap_$DIRTY_FILE

    grep -E "^(10|11|12|13|14|15)" dirty_tiles > generate_bicycle_$DIRTY_FILE

    echo "OpenMap.lt render expired"
	tilestache-clean -c $TILESTACHE_CONFIG_FILE -l all -e pbf --tile-list delete_openmap_$DIRTY_FILE
	tilestache-seed -c $TILESTACHE_CONFIG_FILE -x -l all -e pbf --tile-list generate_openmap_$DIRTY_FILE

    tilestache-clean -c $TILESTACHE_CONFIG_FILE -l bicycle -e pbf --tile-list delete_openmap_$DIRTY_FILE
    tilestache-seed -c $TILESTACHE_CONFIG_FILE -x -l bicycle -e pbf --tile-list generate_bicycle_$DIRTY_FILE

    rm delete_openmap_$DIRTY_FILE generate_openmap_$DIRTY_FILE
    rm generate_bicycle_$DIRTY_FILE
fi

echo "Update end: `date +%c`"

find ./log/ -type f -mtime +7 -name '*.log' -execdir rm -- '{}' +
