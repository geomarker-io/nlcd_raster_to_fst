library(glue)
library(magrittr)
library(rgdal)
library(purrr)

yrs <- c('2001', '2006', '2011', '2016')

#### convert tif to chunked fst files ####

raster_to_fst <- function(product) {
  d <- raster::raster(glue('{product}.tif'))
  d_values <-
    raster::extract(d, 1:raster::ncell(d)) %>%
    as_tibble(.name_repair = 'minimal')
  stopifnot(nrow(d_values) == ncell(d))
  d_values %>%
    purrr::setNames(product)
  fst::write_fst(d_values, glue('{product}.fst'))
}

raster_to_fst('nlcd_2001')
raster_to_fst('nlcd_2006')
raster_to_fst('nlcd_2011')
raster_to_fst('nlcd_2016')

## glue('impervious_{years}') %>%
##   walk(raster_to_fst)

## glue('imperviousdescriptor_{years}') %>%
##   walk(raster_to_fst)

## raster_to_fst('impervious')

## raster_to_fst('imperviousdescriptor')

#### push all to s3 ####

## list.files(pattern = '*.fst') %>%
##   glue('aws s3 cp {.} s3://geomarker/nlcd/{.}')
