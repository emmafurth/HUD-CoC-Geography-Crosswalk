################################################################################
# PROGRAM NAME:    000_clip_tract_shapefile
# PROGRAM AUTHOR:  Tom Byrne (tbyrne@bu.edu)
# PROGRAM PURPOSE: To clip the Tiger Line tract boundary shapefile to the 
#                  HUD CoC boundary shapefile.  this is necessary b/c HUD
#                  CoC boundary shapefile is clipped to shoreline and tract
#                  boundary shapefile is not.  
################################################################################


library(data.table)
library(tigris)
library(stringr)
library(tidycensus)
library(sp)
# library(rgdal)
library(dplyr)
library(tidyr)
# library(maptools)
library(PBSmapping)
library(stringr)
library(sf)
# library(rgeos)
library(car)
library(raster)

# EF 2025 update: used this blog post for suggestions on replacing functionality from rgdal with sf: https://www.r-bloggers.com/2023/06/upcoming-changes-to-popular-r-packages-for-spatial-data-what-you-need-to-do/

# Set output file location and output file name for later use

clipped_file <- "./output/clipped_tract.rds"
output_location <- "./output"

################################################################################
#  Step 1: Read in necessary data
################################################################################

# CoC boundaries
# cocs <- readOGR("./data/CoC_GIS_NatlTerrDC_Shapefile_2017/FY17_CoC_National_Bnd.gdb",
#                 "FY17_CoC_National_Bnd")
cocs <- read_sf("./data/CoC_GIS_NatlTerrDC_Shapefile_2017/FY17_CoC_National_Bnd.gdb",
                "FY17_CoC_National_Bnd")
# TODO: Remove this line
cocs <- cocs |> filter(STATE_NAME == "Maryland")
# Tract boundaries
# tract <- readOGR("./data/tlgdb_2017_a_us_substategeo.gdb/tlgdb_2017_a_us_substategeo.gdb", 
#                  "Census_Tract")
# tract <- read_sf("./data/tlgdb_2017_a_us_substategeo.gdb/tlgdb_2017_a_us_substategeo.gdb", 
#                  "Census_Tract")

# TODO: change this back to nationwide
tract <- read_sf("./data/tlgdb_2017_a_24_md.gdb/tlgdb_2017_a_24_md.gdb", "Census_Tract")

# Set CRS
# tract <- st_transform(tract, CRS("+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs"))

################################################################################
#  Step 1a: make the geometries valid
################################################################################

cocs <- st_make_valid(cocs)
tract <- st_make_valid(tract)

################################################################################
#  Step 2: Dissolve CoC to get rid of individual CoC boundaries and to have
#  just one single boundary for all CoCs
################################################################################

cocs_dissolve <- st_union(cocs)

################################################################################
#  Step 3: Clip tract to CoC boundaries
################################################################################


# Use buffer of width 0 to avoid errors when using intersect function 
tract <- st_buffer(tract, dist = 0)

# clipped_tract <- raster::intersect(cocs_dissolve, tract)
clipped_tract <- st_intersection(tract, cocs_dissolve)

# ggplot(clipped_tract) +
#   geom_sf(fill = "#69b3a2", color = "black") +
#   theme_void()

save(clipped_tract, file = clipped_file)

write_sf(obj = clipped_tract, dsn = output_location, layer = "clipped_tract",
         driver = "ESRI Shapefile")

# remove all files
rm(list = ls())


