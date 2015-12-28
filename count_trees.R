# count_trees.R
# -------------
#
# Author:  Miles Erickson
# License: Freeware
#
# Description:
# Counts the number of trees adjacent to each sidewalk segment in Seattle.
# 
# Background:
# This script has been prepared to complete the "Data Wrangling Project"
# assignment for the Springboard Foundations of Data Science Workshop.
# This project is intended to demonstrate competency in creating a tidy data
# set from real-world data sources.
#
# Additional details are located here:
# https://github.com/mileserickson/springboard_data-wrangling-project

# Load required libraries
library(sp)     # SpatialLinesDataFrame, over()
library(rgdal)  # ReadOGR(), spTransform()
library(rgeos)  # gBuffer()
library(dplyr)  # %>%, group_by, summarise, left_join, etc

# Read sidewalks GeoJSON into a SpatialLinesDataFrame
sidewalks <- readOGR("data/sidewalk-grades-geoJSON-latest.json", "OGRGeoJSON")

# Load street trees shapefile
trees <- readOGR("data/Trees/StatePlane", "Trees")
# trees.wgs84 <- readOGR("data/Trees/WGS84", "Trees")

# Reproject sidewalks to align with trees
sidewalks <- spTransform(sidewalks, CRS(proj4string(trees)))

# Buffer sidewalks by 20 feet
sidewalk_buffers <- gBuffer(sidewalks, width=20, byid=TRUE)
writeOGR(sidewalk_buffers, 'data/sidewalk_buffers', 'sidewalk_buffers', 'ESRI Shapefile')

# Identify which sidewalk each tree adjoins
trees$sidewalk_objectid <- over(trees, sidewalk_buffers)$sidewalk_objectid
## BUG (minor): Each tree is attributed to one sidewalk at most,
##              despite that some sidewalk buffers may overlap slightly
##              near intersections. This could be resolved by performing
##              a spatial left join (e.g. in PostGIS) instead of using
##              sp::over() in R.

# Use dplyr to count the trees within 20ft of each sidewalk
sidewalk_tree_counts <- data.frame(trees) %>%
  group_by(sidewalk_objectid) %>%
  summarise(tree_count = n())

# Add tree count as column in sidewalks data frame
sidewalk_ids <- data.frame(sidewalk_objectid = sidewalks$sidewalk_objectid)
sidewalks$tree_count <- left_join(sidewalk_ids, sidewalk_tree_counts)$tree_count

# Change NAs to 0
NAtoZero <- function(x) {ifelse(is.na(x), 0, x)}
sidewalks$tree_count <- as.numeric(lapply(sidewalks$tree_count, NAtoZero))

# Find lengths of sidewalks
sidewalks$length <- SpatialLinesLengths(sidewalks)

# Normalize tree count by length
sidewalks$trees_per_ft <- sidewalks$tree_count / sidewalks$length

