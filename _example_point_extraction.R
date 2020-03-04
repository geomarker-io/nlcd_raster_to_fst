#### example point application
library(sf)
library(dplyr)
library(tidyr)

source("./get_nlcd_data.R")
source("./nlcd_definitions.R")

raw_data <- readr::read_csv("test/my_address_file_geocoded.csv")
raw_data$.row <- seq_len(nrow(raw_data))

d <-
  raw_data %>%
  select(.row, lat, lon) %>%
  na.omit() %>%
  nest(.rows = c(.row)) %>%
  st_as_sf(coords = c("lon", "lat"), crs = 4326)

# reproject points into NLCD projection for overlay
d <- d %>%
  sf::st_transform(crs = raster::crs(r_nlcd_empty))

# get NLCD cell number for each point
d <- d %>%
  mutate(nlcd_cell = raster::cellFromXY(r_nlcd_empty, as(d, "Spatial")))

# download the NLCD chunks ahead of time
download_nlcd_chunks(d$nlcd_cell)

# get NLCD data for each cell number
d <- d %>%
  mutate(nlcd_data = mappp::mappp(nlcd_cell, get_nlcd_data))

# merge back to raw data
d_out <- d %>%
  unnest(.rows) %>%
  st_drop_geometry() %>%
  left_join(raw_data, ., by = ".row") %>%
  select(-.row, -nlcd_cell)

# make into long format and replace numbers with legend values
d_out <- d_out %>%
  unnest(nlcd_data) %>%
  pivot_longer(cols = starts_with(c("nlcd", "impervious")), names_to = c("product", "year"), names_sep = "_") %>%
  pivot_wider(names_from = product, values_from = value) %>%
  left_join(nlcd_legend, by = c("nlcd" = "value")) %>%
  select(-nlcd) %>%
  left_join(imperviousness_legend, by = c("imperviousdescriptor" = "value")) %>%
  select(-imperviousdescriptor)

# write to csv
readr::write_csv(d_out, "./test/my_address_file_geocoded_nlcd.csv")

# save as nested RDS file
d_out %>%
  nest(nlcd_data = c(year, impervious, landcover_class, road_type, green, landcover))
