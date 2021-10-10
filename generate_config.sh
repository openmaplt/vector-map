#!/usr/bin/env bash
GLOBIGNORE="*"
CONFIG_TEMPLATE='./config.toml.template'
CONFIG_FILE=${1:-./config.toml}
CONFIG_TEMP=$CONFIG_FILE'_temp'
CACHE_DIR=${2:-/home/openmap/cache}
REGEX='%(.*?)%'

cp $CONFIG_TEMPLATE $CONFIG_TEMP

while read line;
do
   if [[ $line =~ $REGEX ]]
   then
      sql_file=${BASH_REMATCH[1]}
      sql=`cat $sql_file`
      sql=`echo $sql | sed "s|&&|##|g"`
      sed -i "s|$BASH_REMATCH|$sql|g" $CONFIG_TEMP
   fi
done < $CONFIG_TEMP

sed "s|##|\&\&|g" $CONFIG_TEMP > $CONFIG_FILE
sed "s|__CACHE_DIR__|$CACHE_DIR|g" $CONFIG_TEMP > $CONFIG_FILE
