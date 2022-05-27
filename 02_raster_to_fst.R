library(glue)
library(magrittr)
## library(rgdal)
library(purrr)
library(tibble)

## list.files("./nlcd_tif", full.names = TRUE)

yrs <- c("2001", "2006", "2011", "2016")
product_names <- c("nlcd", "impervious", "imperviousdescriptor")

yrs_product_names <- map(product_names, ~ paste0(., "_", yrs)) %>% unlist()

#### convert tif to chunked fst files ####

r_all <- raster::stack(glue("./nlcd_tif/{yrs_product_names}.tif"))
dir.create("./nlcd_fst")

chunk_size <- 1e+07
n_chunks <- (raster::ncell(r_all) %/% chunk_size) + 1

write_chunk_as_fst <- function(chnk) {
  chunk_cell_numbers <-
    seq.int(
      from = chnk * chunk_size,
      to = chnk * chunk_size + chunk_size,
      by = 1
    )
  d_values <-
    raster::extract(r_all, chunk_cell_numbers) %>%
    as_tibble()
  fst::write_fst(d_values, glue("./nlcd_fst/nlcd_chunk_{chnk}.fst"))
  return(invisible(NULL))
}

# extracting for raster cell 0 results in NA, so no problems with that
mappp::mappp(0:n_chunks, write_chunk_as_fst, parallel = TRUE) %>%
  invisible()
