#Tom's map of London Football Violence
library(tidyverse)
library(maptools)
library(RColorBrewer)
library(classInt)
library(OpenStreetMap)
library(sp)
library(rgeos)
library(tmap)
library(tmaptools)
library(sf)
library(rgdal)
library(geojsonio)
EW <- geojson_read("http://geoportal.statistics.gov.uk/datasets/8edafbe3276d4b56aec60991cbddda50_2.geojson", what = "sp")
#pull out london using grep and the regex wildcard for'start of the string' (^) to to look for the bit of the district code that relates to London (E09) from the 'lad15cd' column in the data slot of our spatial polygons dataframe
LondonMap <- EW[grep("^E09",EW@data$lad15cd),]
#plot it using the base plot function
qtm(LondonMap)
LondonMapSF <- st_as_sf(LondonMap)
FootballData <- read_csv("Boroughs_and_clubs.csv")
#append the data to the geometries
LondonMapSF <- append_data(LondonMapSF,FootballData, key.shp = "lad15cd", key.data = "borough_code", ignore.duplicates = TRUE)
#plot a choropleth
qtm(LondonMapSF, fill = "arrests_per_capacity")
footballmap <- read_osm(LondonMapSF)
qtm(footballmap) + 
  tm_shape(LondonMapSF) + 
  tm_polygons("arrests_per_capacity",
              style="pretty",
              palette="PuRd",
              midpoint=NA,
              title="Average arrests per ground capacity*1000",
              alpha = 0.8) + 
  tm_compass(position = c("left", "bottom"),type = "arrow") + 
  tm_scale_bar(position = c("left", "bottom")) +
  tm_layout(title = "Football Fan Violence by Borough", title.position = c("right", "top"), legend.position = c("right", "bottom"))

