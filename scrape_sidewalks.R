# scrape_sidewalks.R
# -------------
#
# Author:  Miles Erickson
# License: Freeware
#
# Description:
# Scrapes the City of Seattle sidewalk dataset from an ESRI MapServer API endpoint.
# This public dataset should be available for direct download via data.seattle.gov, but the
# server is returning a "Bad Request" error that City staff have been unable to resolve
# as of December 2015.
# 
# Background:
# This script has been prepared to complete the "Data Wrangling Project"
# assignment for the Springboard Foundations of Data Science Workshop.
# This project is intended to demonstrate competency in creating a tidy data
# set from real-world data sources.
#
# Additional details are located here:
# https://github.com/mileserickson/springboard_data-wrangling-project# Required libraries

# Required libraries
require(rjson)

# Scrape JSON from ArcGIS REST API
#
# Sample API Endpoint URL for objectID 0-10:
# 'https://gisrevprxy.seattle.gov/arcgis/rest/services/SDOT_EXT/DSG_datasharing/MapServer/36/query?where=%28OBJECTID+%3E+0%29+AND+%28OBJECTID+%3C%3D+10%29&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=*&returnGeometry=true&returnTrueCurves=true&maxAllowableOffset=&geometryPrecision=&outSR=&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&returnDistinctValues=false&resultOffset=&resultRecordCount=&f=pjson'
# Note: ESRI recommends using f=json for speed, or f=pjson for readbility of the raw output.

# Initialize empty list to store scraped JSON data
raw.json <- list()

# Get number of records in dataset
record.count <- fromJSON(file='https://gisrevprxy.seattle.gov/arcgis/rest/services/SDOT_EXT/DSG_datasharing/MapServer/36/query?where=1%3D1&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=*&returnGeometry=true&returnTrueCurves=true&maxAllowableOffset=&geometryPrecision=&outSR=&returnIdsOnly=false&returnCountOnly=true&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&returnDistinctValues=false&resultOffset=&resultRecordCount=&f=pjson')
record.count <- record.count$count  # strip away list object

# Set name of key field for chunking
key.field = 'OBJECTID'

# The ESRI MapServer API endpoint allows only 1000 records to be queried at a time
chunk.size <- 1000
chunks <- seq(0, record.count, chunk.size)  # Make a list of chunk starting points

# Scrape each chunk of 1000 
for(chunk in chunks) {

  # Determine starting and ending OBJECTID values for current chunk
  id.from <- as.character(chunk)
  id.to <- as.character(chunk + chunk.size)

  # Compose URL for current chunk
  # TODO: try deleting blank GET parameters (e.g. 'text=') to simplify URL
  url <- paste('https://gisrevprxy.seattle.gov/arcgis/rest/',
              'services/SDOT_EXT/DSG_datasharing/',
              'MapServer/36/query?where=%28', key.field, '+%3E+', 
              id.from, '%29+AND+%28', key.field, '+%3C%3D+', id.to, 
              '%29&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope',
              '&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=',
              '&outFields=*&returnGeometry=true&returnTrueCurves=true',
              '&maxAllowableOffset=&geometryPrecision=&outSR=&returnIdsOnly=false',
              '&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=',
              '&outStatistics=&returnZ=false&returnM=false&gdbVersion=',
              '&returnDistinctValues=false&resultOffset=&resultRecordCount=',
              '&f=json',  # ESRI recommends f=json for speed, f=pjson for readability
               sep = '')
  print(paste('Scraping chunk with', key.field, '>=', id.from, 'and', key.field, '<', id.to, '...'))
  print(paste('URL:', url))
  
  # Scrape chunk and add to raw.json list
  raw.json[[length(raw.json) + 1]] <- fromJSON(file=url)
}
print('Done scraping!')

