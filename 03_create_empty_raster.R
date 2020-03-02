library(glue)
library(magrittr)
library(raster)

sg <- function(...) system(glue(...))

long_name <- "NLCD_Land_Cover_L48_20190424_full_zip"
short_name <- "nlcd"

sg("aws s3 cp s3://mrlc/NLCD_Land_Cover_L48_20190424_full_zip.zip nlcd.zip")
sg("unzip nlcd.zip")
sg("rm nlcd.zip")
sg("gdal_translate -of GTiff NLCD_2016_Impervious_L48_20190424.img nlcd_2016.tif")

r_nlcd <- raster::raster("nlcd_2016.tif")

r_nlcd

r_nlcd_empty <-
  raster::raster(
    nrows = 104424,
    ncols = 161190,
    xmn = -2493045,
    xmx = 2342655,
    ymn = 177285,
    ymx = 3310005,
    crs = "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0",
    resolution = c(30, 30),
    vals = NULL
  )

raster::compareRaster(r_nlcd, r_nlcd_empty, values = FALSE)
