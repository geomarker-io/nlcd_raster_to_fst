# nlcd_raster_to_fst

This repository downloads and transforms NLCD rasters into distributed chunks of `.fst` files for downstream use in the [`addNlcdData` R package](https://github.com/geomarker-io/addNlcdData).

## reproducibility

- package dependencies are documented using `renv`
- this code also relies on the `aws cli` being available
- the script relies heavily on system calls and so its behavior may change depending on the host operating system
- ideally, the `cole-brokamp/singr:4.0` singularity image is used to run the code here reproducibly

## creating fst chunk files

- `01_nlcd_to_raster.R` downloads, extracts, and converts NLCD files to `.tif` files
    - NLCD files are stored at `s3://geomarker/nlcd/nlcd_tif/` and include `impervious_{2001,2006,2011,2016}.tif`, `imperviousdescriptor_{2001,2006,2011,2016}.tif`, `nlcd_{2001,2006,2011,2016}.tif`, and `treecanopy{2011,2016}.tif`
- `02_raster_to_fst.R` converts the `.tif` files into one large raster stack and breaks the data into `.fst` files representing fragemented chunks on disk
    - NLCD data is stored as a folder of 1,685 `.fst` files at `s3://geomarker/nlcd/nlcd_fst/`
    - their sizes vary, but each file is 28.5 MB in size on average (all 1,685 files take about 48 GB on disk)
- `03_create_empty_raster.R` downloads raster file to get info to use to create "empty raster" for lookup purposes

## reading data from fst files

- each file is a "chunk" of the total data and is named like `nlcd_chunk_{chunk_number}.fst`
-  see the [`addNlcdData` R package](https://github.com/geomarker-io/addNlcdData) for functions to automatically download and extract data based on lat/lon (or NLCD cell number) and date
- the number of chunk files needed depends on the geographic extent of the input spatial data and only the chunks necessary for the input spatial data are downloaded