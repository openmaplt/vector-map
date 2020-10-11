#!/bin/bash
set -eu
here=$(dirname "$0")

psql osm -U osm < "${here}/upiu_baseinai.sql"
psql osm -U osm < "${here}/merge_water.sql"
psql osm -U osm < "${here}/touch.sql"
psql osm -U osm < "${here}/process.sql"
psql osm -U osm < "${here}/process_plot.sql"
