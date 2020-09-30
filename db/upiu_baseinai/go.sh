#!/bin/bash
set -e
psql osm < upiu_baseinai.sql
psql osm < merge_water.sql
psql osm < touch.sql
psql osm < process.sql
psql osm < process_plot.sql
