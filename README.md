# vector-map
Vektorinis Lietuvos OpenStreetMap žemėlapis

Šiame projekte yra trys dalys:
1. Vektorinių kaladėlių generavimo užklausos (skirtos TileStache).
2. Vektorinio žemėlapio, naudojančio sukurtas vektorines kaladėles, stiliai.
3. Žemėlapis, naudojantis vektorines kaladėles, stilius, kitas funkcionalumas.

Wiki puslapiuose (https://github.com/openmaplt/vector-map/wiki) rasite informaciją apie tai, kokie sluoksniai grąžinami vektorinėse kaladėlėse: kokie objektai, kokiuose masteliuose, atributų sąrašas su galimomis reikšmėmis.

## Docker

Docker gali būti naudojamas lokalioje aplinkoje dirbant su vektoriniais duomenimis arba stiliais. Būtinas veikiantis `docker` ir `docker-compose`

Paleidimas pirmą kartą arba po atnaujinimų:
* `./bin/run.sh`
* `./bin/init.sh`

Visais kitais kartais:
* `./bin/run.sh` paleisti servisus
* `./bin/stop.sh` sustabdyti viską

### Servisai

* http://localhost žemėlapio puslapis
* http://localhost:8888 [Maputnik stiliaus redaktorius](http://github.com/maputnik/editor)
* localhost:5432 PostgreSQL duomenų bazė, user: osm, password: osm
* http://localhost:8080 TileStache vektorinių kaladėlių servisas

