#!/usr/bin/env bash
echo "Start update Nominatim"    

sudo -u postgres /home/nominatim/build/utils/update.php --import-diff ./change.osc --index                                                                

echo "Finish update Nominatim"
