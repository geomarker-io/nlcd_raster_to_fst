download_nlcd_chunk <- function(nlcd_chunk_number) {
  dir.create("./nlcd_fst/", showWarnings = FALSE)
  message(glue::glue("downloading s3://geomarker/nlcd/nlcd_chunk_{nlcd_chunk_number}.fst"))
  download.file(
    url = glue::glue(
                  "https://geomarker.s3.us-east-2.amazonaws.com/",
                  "nlcd/nlcd_fst/", "nlcd_chunk_{nlcd_chunk_number}.fst"
                ),
    destfile = glue::glue("./nlcd_fst/nlcd_chunk_{nlcd_chunk_number}.fst")
  )
}

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
  purrr::walk(nlcd_chunks_needed, download_nlcd_chunk)
}
