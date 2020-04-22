# nlcd_raster_to_fst

## creating fst files

This portion of the repository contains an R script for downloading and transforming NLCD rasters into `.fst` files. In addition to the package dependencies documented in `renv`, it relies on the `aws cli` being available too.

This script relies heavily on system calls and so its behavior may change depending on the host operating system. Ideally, the `cole-brokamp/singr` singularity image would be used to run the script.

- `01_nlcd_to_raster.R` downloads, extracts, and converts NLCD files to `.tif` files
    - NLCD files are stored at s3://geomarker/nlcd/nlcd_tif/ and include `impervious_{2001,2006,2011,2016}.tif`, `imperviousdescriptor_{2001,2006,2011,2016}.tif`, `nlcd_{2001,2006,2011,2016}.tif`, and `treecanopy{2011,2016}.tif`
- `02_raster_to_fst.R` converts the `.tif` files into `.fst` files
    - NLCD data is stored as a folder of 1,685 `.fst` files at `s3://geomarker/nlcd/nlcd_fst/`
- `03_create_empty_raster.R` downloads raster file to get info to use to create "empty raster" for lookup purposes

## reading data from fst files

- each file is a "chunk" of the total data and is named like `nlcd_chunk_{chunk_number}.fst`, see `get_nlcd_data.R` for functions to extract data automatically based on NLCD cell number, year, and product name
- chunk files will be automatically downloaded to the `./nlcd_fst/` folder in the working directory; the number of chunk files needed depends on the geographic extent of the input spatial data; their sizes vary, but each file is 28.5 MB in size on average (all 1,685 files take about 48 GB on disk)
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

## getting data for an sf object

An "empty raster" that can be quickly used to match geospatial features with NLCD cells as well as definitions for the different integer codes corresponding to land classes are defined in `nlcd_definitions.R`

See the example files for how to implement code to extract values from sf objects:

- `_example_point_extraction.R`
- `_example_polygon_extraction.R`

These examples return classified land based on the green/non-green classification system described in https://doi.org/10.1016/j.ufug.2016.10.013

## NLCD data details

- Variables returned from .fst files for a single point include:
    - `impervious`: percent impervious
    - `landcover_class`: landcover classfication category
    - `landcover`: landcover classification
    - `green`: TRUE/FALSE if landcover classification in any category except water, ice/snow, developed medium intensity, developed high intensity, rock/sand/clay
    - `road_type`: impervious descriptor category (or "non-impervious")

- Note that the NLCD categories correspond exactly to fraction imperviousness

    nlcd category | fraction impervious
    --------------|--------------------
    developed open | < 20%
    developed low | 20 - 49%
    developed medium | 50 - 79%
    developed high | 80 - 100%
    any other | 0%

- See [_example_polygon_extraction.R](_example_polygon_extraction.R) for implementations as percentages for polygons and buffers around points
