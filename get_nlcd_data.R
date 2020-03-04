# download nlcd chunk only if it doesn't already exist
download_nlcd_chunk <- function(nlcd_chunk_number) {
  dir.create("./nlcd_fst/", showWarnings = FALSE)
  nlcd_file <- glue::glue("./nlcd_fst/nlcd_chunk_{nlcd_chunk_number}.fst")
  if (file.exists(nlcd_file)) {
    message(glue::glue("{nlcd_file} already exists"))
    invisible(return(NULL))
  }
  message(glue::glue("downloading s3://geomarker/nlcd/nlcd_chunk_{nlcd_chunk_number}.fst to {nlcd_file}"))
  download.file(
    url = glue::glue(
      "https://geomarker.s3.us-east-2.amazonaws.com/",
      "nlcd/nlcd_fst/", "nlcd_chunk_{nlcd_chunk_number}.fst"
    ),
    destfile = nlcd_file
  )
}

# get raw nlcd values for specific cell number, year, and product
get_nlcd_data <- function(nlcd_cell_number,
                          year = c(2001, 2006, 2011, 2016),
                          product = c("nlcd", "impervious", "imperviousdescriptor")) {
  if (length(nlcd_cell_number) > 1) {
    warning("nlcd_cell is longer than one; processing only the first value")
    nlcd_cell <- nlcd_cell_number[1]
  }
  nlcd_chunk <- nlcd_cell_number %/% 1e+07
  nlcd_row <- nlcd_cell_number %% 1e+07
  nlcd_file <- glue::glue("./nlcd_fst/nlcd_chunk_{nlcd_chunk}.fst")
  nlcd_columns <- unlist(purrr::map(year, ~ glue::glue("{product}_{.}")))
  if (!file.exists(nlcd_file)) download_nlcd_chunk(nlcd_chunk)
  out <- fst::read_fst(
    path = nlcd_file,
    from = nlcd_row,
    to = nlcd_row,
    columns = nlcd_columns
  )
  out <- tibble::as_tibble(out)
  out
}

# download all chunks needed for nlcd multiple cell numbers ahead of time
download_nlcd_chunks <- function(nlcd_cell_numbers) {
  nlcd_chunks_needed <- unique(nlcd_cell_numbers %/% 1e+07)
  message("downloading ", length(nlcd_chunks_needed), " total chunk files to ./nlcd_fst/")
  purrr::walk(nlcd_chunks_needed, download_nlcd_chunk)
}

# define empty nlcd raster
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

# define legends for raster values (and our green codes)
nlcd_legend <-
  tibble::tribble(
    ~value, ~landcover_class, ~landcover, ~green,
    11, "water", "water", FALSE,
    12, "water", "ice/snow", FALSE,
    21, "developed", "developed open", TRUE,
    22, "developed", "developed low intensity", TRUE,
    23, "developed", "developed medium intensity", FALSE,
    24, "developed", "developed high intensity", FALSE,
    31, "barren", "rock/sand/clay", FALSE,
    41, "forest", "deciduous forest", TRUE,
    42, "forest", "evergreen forest", TRUE,
    43, "forest", "mixed forest", TRUE,
    51, "shrubland", "dwarf scrub", TRUE,
    52, "shrubland", "shrub/scrub", TRUE,
    71, "herbaceous", "grassland", TRUE,
    72, "herbaceous", "sedge", TRUE,
    73, "herbaceous", "lichens", TRUE,
    74, "herbaceous", "moss", TRUE,
    81, "cultivated", "pasture/hay", TRUE,
    82, "cultivated", "cultivated crops", TRUE,
    90, "wetlands", "woody wetlands", TRUE,
    95, "wetlands", "emergent herbaceous wetlands", TRUE
  )

imperviousness_legend <-
  tibble::tribble(
    ~value, ~road_type,
    0, "non-impervious",
    1, "primary_urban",
    2, "primary_nonurban",
    3, "secondary_urban",
    4, "secondary_nonurban",
    5, "tertiary_urban",
    6, "tertiary_nonurban",
    7, "thinned_urban",
    8, "thinned_nonurban",
    9, "nonroad_urban",
    10, "nonroad_nonurban",
    11, "energy_prod_urban",
    12, "energy_prod_nonurban",
  )
