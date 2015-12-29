# run_analysis.R
# --------------
#
# Author:  Miles Erickson
# License: Freeware
#
# Description:
# Converts the proprietary ESRI JSON format to GeoJSON.
# This works for line objects only, but you are free to adapt this code to
# work with other spatial data types. Knowledge of the GeoJSON format is
# helpful, as is a willingness to dig into ESRI's proprietary format.
# 
# Background:
# This script has been prepared to complete the "Data Wrangling Project"
# assignment for the Springboard Foundations of Data Science Workshop.
# This project is intended to demonstrate competency in creating a tidy data
# set from real-world data sources.
#
# Additional details:
# https://github.com/mileserickson/springboard_data-wrangling-project# Load required libraries

# Required libraries
require(rjson) # toJSON()

# Initialize lists
FeatureCollection <- list(type = "FeatureCollection")
features <- list()

chunk.count <- length(raw.json)

# Iterate through features & add each to features list
for(i in 1:length(raw.json)) {
  print(paste('chunk #', i, 'of', chunk.count))
  fc <- raw.json[[i]][6][1]$features
  for(j in 1:length(fc)) {
    feat <- raw.json[[i]][6][1]$features[[j]]
    feature <- list(type = "Feature")
    # Output geometry    
    geometry <- list(type = "LineString")
    coordinates <- list()
    if(length(feat$geometry$paths) >= 1) {
      path <- feat$geometry$paths[[1]]
    } else {
      # Warn if a feature doesn't include any geospatial paths
      print(paste(i, j, 'paths:', length(feat$geometry$paths)))
    }
    for(k in 1:length(path)) {
      p <- path[[k]]  # p = point
      coordinates[[length(coordinates) + 1]] <- c(p[1], p[2])
    }
    geometry[["coordinates"]] <- coordinates
    feature[["geometry"]] <- geometry
    
    # Collect attributes for each feature in properties list
    props <- feat$attributes
    labs <- labels(feat$attributes)
    properties <- list()
    for(l in 1:length(props)) {
      properties[labs[l]] <- props[l]
    }
    
    feature[["properties"]] <- properties
    features[[length(features) + 1]] <- feature
  }  # /fc
}  # /raw.json

FeatureCollection[["features"]] <- features

# TODO: troubleshoot coordinate system designation in GeoJSON output
# Specify coordinate system in GeoJSON file (not working)
#   crs <- list(type = "name", properties = list(name = "EPSG:2926"))
#   FeatureCollection[["crs"]] <- crs

# output GeoJSON to file
jsonFile <- file("data/sidewalks.json", "w")
GeoJSON <- toJSON(FeatureCollection)
writeLines(GeoJSON, jsonFile)
close(jsonFile)

