# run_analysis.R
# --------------
#
# Author:  Miles Erickson
# License: Freeware
#
# Description:
# Gathers and analyzes data to count the number of trees adjacent to each sidewalk segment
# within the city of Seattle.
# 
# Background:
# This script has been prepared to complete the "Data Wrangling Project"
# assignment for the Springboard Foundations of Data Science Workshop.
# This project is intended to demonstrate competency in creating a tidy data
# set from real-world data sources.
#
# Additional details:
# https://github.com/mileserickson/springboard_data-wrangling-project

# Load required libraries
library(sp)     # SpatialLinesDataFrame, over()
library(rgdal)  # ReadOGR(), spTransform()
library(rgeos)  # gBuffer()
library(dplyr)  # %>%, group_by, summarise, left_join, etc
library(rjson)  # toJSON()

# Scrape sidewalk data from the City of Seattle ESRI GIS Map Server
source('scrape_sidewalks.R')

# Convert scraped ESRI JSON to GeoJSON and output to a file
source('output_geojson.R')

# Read the generated sidewalks GeoJSON file into a SpatialLinesDataFrame
sidewalks <- readOGR("data/sidewalks.json", "OGRGeoJSON")

# Count the trees, adding sidewalks$tree_count and sidewalks$trees_per_ft
source('count_trees.R')