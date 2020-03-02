# nlcd_raster_to_fst

## creating fst files

This repository contains an R script for downloading and transforming NLCD rasters into `.fst` files. In addition to the package dependencies documented in `renv`, it relies on the `aws cli` being available too.

This script relies heavily on system calls and so its behavior may change depending on the host operating system. Ideally, the `cole-brokamp/singr` singularity image would be used to run the script.

- `01_nlcd_to_raster.R` downloads, extracts, and converts NLCD files to `.tif` files
- NLCD files are stored at s3://geomarker/nlcd/nlcd_tif/ and include `impervious_{2001,2006,2011,2016}.tif`, `imperviousdescriptor_{2001,2006,2011,2016}.tif`, `nlcd_{2001,2006,2011,2016}.tif`, and `treecanopy{2011,2016}.tif`
- `02_raster_to_fst.R` converts the `.tif` files into `.fst` files
- NLCD data is stored as a folder of 1,685 `.fst` files at `s3://geomarker/nlcd/nlcd_fst/`

## reading data from fst files

- each file is a "chunk" of the total data and is named like `nlcd_chunk_{chunk_number}.fst`, see `get_nlcd_data.R` for functions to extract data automatically based on NLCD cell number, year, and product name
- chunk files will be automatically downloaded to the `./nlcd_fst/` folder in the working directory; the number of chunk files needed depends on the geographic extent of the input spatial data; their size varies, but each file is 28.5 MB in size on average (all 1,685 files take about 48 GB on disk)
- a quick example is:

```r
source('get_nlcd_data.R')

# choose random nlcd cell numbers for example
nlcd_cells <- sample(1:16832104560, 5)

get_nlcd_data(nlcd_cells[1])

purrr::map_dfr(nlcd_cells, get_nlcd_data)

purrr::map_dfr(nlcd_cells + 100000, get_nlcd_data)

mappp::mappp(nlcd_cells, get_nlcd_data, parallel = TRUE)
```

## finding cell numbers from an sf object
