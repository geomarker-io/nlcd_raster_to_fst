# nlcd_raster_to_fst

This repository contains an R script for downloading and transforming NLCD rasters into `.fst` files. In addition to the package dependencies documented in R, it relies on the `aws cli` being available too.

This script relies heavily on system calls and so its behavior may change depending on the host operating system. Ideally, the `cole-brokamp/singr` singularity image would be used to run the script.

- `nlcd_to_raster.R` downloads, extracts, and converts NLCD files to `.tif` files
- `raster_to_fst.R` converts the `.tif` files into `.fst` files

Currently, NLCD files are stored at s3://geomarker/nlcd/nlcd_tif/ and include `impervious_{2001,2006,2011,2016}.tif`, `imperviousdescriptor_{2001,2006,2011,2016}.tif`, `nlcd_{2001,2006,2011,2016}.tif`, and `treecanopy{2011,2016}.tif`
