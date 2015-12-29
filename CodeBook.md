# sidewalks.RData

## Variables

* sidewalk_id: unique identifier for each row
* sidewalk_objectid: identifier linking to City of Seattle sidewalk metadata (not unique, many sidewalk_objectid values have multiple segments)
* description: identifies street name and block (text)

## Data

* sidewalks.RData: tidy sidewalk data set (SpatialLinesDataFrame)
* * [Sidewalks](https://data.seattle.gov/Transportation/SDOT-Sidewalks/pxgh-b4sz/about) (City of Seattle): City of Seattle sidewalk dataset (source data)
* [Trees in the Public Right of Way](https://data.seattle.gov/Transportation/Trees-in-the-Public-Right-of-Way/tiq5-syif/about) (City of Seattle): City of Seattle street tree dataset (source data)

## Transformations

* run_analysis.R: runs scripts in sequence
* scrape_sidewalks.R: retrieve sidewalks from City of Seattle map server
* output_geojson.R: convert ESRI JSON to GeoJSON
* count_trees.R: align projections, buffer sidewalks, count trees within buffers

Refer to comments in the individual R scripts for details of the transformations.
