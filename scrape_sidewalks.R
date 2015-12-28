# Required libraries
require(rgdal)
require(rjson)

# Scrape JSON from ArcGIS REST API
#
# Sample API Endpoint URL for objectID 0-10:
# 'https://gisrevprxy.seattle.gov/arcgis/rest/services/SDOT_EXT/DSG_datasharing/MapServer/36/query?where=%28OBJECTID+%3E+0%29+AND+%28OBJECTID+%3C%3D+10%29&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=*&returnGeometry=true&returnTrueCurves=true&maxAllowableOffset=&geometryPrecision=&outSR=&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&returnDistinctValues=false&resultOffset=&resultRecordCount=&f=pjson'

# Initialize empty list to store scraped JSON data
raw.json <- list()

# Get number of records in dataset
record.count <- fromJSON(file='https://gisrevprxy.seattle.gov/arcgis/rest/services/SDOT_EXT/DSG_datasharing/MapServer/36/query?where=1%3D1&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=*&returnGeometry=true&returnTrueCurves=true&maxAllowableOffset=&geometryPrecision=&outSR=&returnIdsOnly=false&returnCountOnly=true&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&returnDistinctValues=false&resultOffset=&resultRecordCount=&f=pjson')
record.count <- record.count$count  # strip away list object

# The ESRI MapServer API endpoint allows only 1000 records to be queried at a time
chunk.size <- 1000
chunks <- seq(0, record.count, chunk.size)  # Make a list of chunk starting points

# Scrape each chunk of 1000 
for(chunk in chunks) {
  id.from <- as.character(chunk)
  id.to <- as.character(chunk + chunk.size)
  url <- paste('https://gisrevprxy.seattle.gov/arcgis/rest/services/SDOT_EXT/DSG_datasharing/MapServer/36/query?where=%28OBJECTID+%3E+', 
               id.from, '%29+AND+%28OBJECTID+%3C%3D+', id.to, 
               '%29&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=*&returnGeometry=true&returnTrueCurves=true&maxAllowableOffset=&geometryPrecision=&outSR=&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&returnDistinctValues=false&resultOffset=&resultRecordCount=&f=pjson',
               sep = '')
  print(paste('from', id.from, 'to', id.to))
  print(url)
  raw.json[[length(raw.json) + 1]] <- fromJSON(file=url)  # add scraped chunk to raw_json
}


