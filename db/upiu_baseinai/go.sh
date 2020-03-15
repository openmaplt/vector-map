#!/bin/bash
psql osm -U osm < upiu_baseinai.sql
psql osm -U osm < merge_water.sql
psql osm -U osm < touch.sql
psql osm -U osm < process.sql
psql osm -U osm < process_plot.sql
