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
system.time(cocs <- read_sf("./data/CoC_GIS_NatlTerrDC_Shapefile_2017/FY17_CoC_National_Bnd.gdb",
                "FY17_CoC_National_Bnd"))

# system.time(cocs <- cocs |> filter(STATE_NAME == "Alabama")) # TODO: Remove this line
# Tract boundaries
# tract <- readOGR("./data/tlgdb_2017_a_us_substategeo.gdb/tlgdb_2017_a_us_substategeo.gdb",
#                  "Census_Tract")
system.time(tract <- read_sf("./data/tlgdb_2017_a_us_substategeo.gdb/tlgdb_2017_a_us_substategeo.gdb",
                 "Census_Tract"))

# TODO: Remove this line --v
# system.time(tract <- tract %>% filter(startsWith(GEOID, '01'))) # Filters to just Alabama

# TODO: change this back to nationwide
# system.time(tract <- read_sf("./data/tlgdb_2017_a_24_md.gdb/tlgdb_2017_a_24_md.gdb", "Census_Tract"))

# Set CRS
# tract <- st_transform(tract, CRS("+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs"))

################################################################################
#  Step 1a: make the geometries valid
################################################################################

system.time(cocs <- st_make_valid(cocs))
system.time(tract <- st_make_valid(tract))

################################################################################
#  Step 2: Dissolve CoC to get rid of individual CoC boundaries and to have
#  just one single boundary for all CoCs
################################################################################

system.time(cocs_dissolve <- st_union(cocs))

################################################################################
#  Step 3: Clip tract to CoC boundaries
################################################################################


# Use buffer of width 0 to avoid errors when using intersect function
system.time(tract <- st_buffer(tract, dist = 0))
system.time(tract <- tract %>% mutate(original_area = st_area(SHAPE)))
# system.time(buffer_tract <- st_buffer(tract, dist = 0))

# clipped_tract <- raster::intersect(cocs_dissolve, tract)
system.time(clipped_tract <- st_intersection(tract, cocs_dissolve))

system.time(clipped_tract <- clipped_tract %>% mutate(intersect_area = st_area(SHAPE)))
system.time(clipped_tract <- clipped_tract %>% mutate(pct_orig_area = (intersect_area / original_area)*100))

system.time(clipped_tract <- st_make_valid(clipped_tract))

# omitted_tracts <- clipped_tract %>% filter(!(st_geometry_type(SHAPE) %in% c("POLYGON","MULTIPOLYGON"))) %>%
#   mutate(Geom_Type = st_geometry_type(SHAPE)) %>%
#   st_drop_geometry()
# system.time(clipped_tract <- clipped_tract %>% filter(st_geometry_type(SHAPE) %in% c("POLYGON","MULTIPOLYGON")))


# "01015001100" "01015001202" "01015001500" "01015002000" "01015002600" "01033021000"
# [7] "01049960500" "01049960600" "01049960700" "01055010402" "01055011001" "01055011100"
# [13] "01095031000" "01113030402" "01113031000" "01113031100" "01113031200"

# clipped_tract <- clipped_tract %>% filter(st_geometry_type(SHAPE) == "POLYGON")

# system.time(clipped_tract <- st_make_valid(clipped_tract))

# ggplot(clipped_tract) +
#   geom_sf(fill = "#69b3a2", color = "black") +
#   theme_void()

system.time(save(clipped_tract, file = clipped_file))

# write.csv(omitted_tracts, "omitted_tracts.csv")

system.time(write_sf(obj = clipped_tract, dsn = output_location, layer = "clipped_tract",
         driver = "ESRI Shapefile"))

# remove all files
rm(list = ls())


