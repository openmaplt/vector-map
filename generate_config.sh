#!/usr/bin/env bash
GLOBIGNORE="*"
CONFIG_TEMPLATE='./config.toml.template'
CONFIG_FILE='./config.toml'
CONFIG_TEMP=$CONFIG_FILE'_temp'
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

sed -i "s|##|\&\&|g" $CONFIG_TEMP

PGHOST=${PGHOST:-"localhost"} envsubst < $CONFIG_TEMP > $CONFIG_FILE
rm $CONFIG_TEMP