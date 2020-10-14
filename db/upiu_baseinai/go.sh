#!/bin/bash
set -xeu
here=$(dirname "$0")

exec psql osm -U osm \
    -f "${here}/upiu_baseinai.sql" \
    -f "${here}/merge_water.sql" \
    -f "${here}/touch.sql" \
    -f "${here}/process.sql" \
    -f "${here}/process_plot.sql"
