from os import environ
import TileStache

# read config file or URL from environment, defaults to tiles.cfg
application = TileStache.WSGITileServer('/home/osm/tiles.cfg')
