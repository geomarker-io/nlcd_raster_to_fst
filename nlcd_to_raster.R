library(glue)
library(magrittr)

sg <- function(...) system(glue(...))

yrs <- c('2001', '2006', '2011', '2016')

#### converting to rasters ####

# s3://mrlc/NLCD_Land_Cover_L48_20190424_full_zip.zip

long_name <- 'NLCD_Land_Cover_L48_20190424_full_zip'
short_name <- 'nlcd'

sg('aws s3 cp s3://mrlc/{long_name}.zip {short_name}.zip')
sg('unzip {short_name}.zip')
sg('rm {short_name}.zip')

glue('gdal_translate -of GTiff NLCD_{yrs}_Impervious_L48_20190424.img nlcd_{yrs}.tif') %>%
  walk(system)

sg('rm *.xml *.rrd *.rde *.img *.ige')
sg('rm -r NLCD2016_spatial_metadata')

# s3://mrlc/NLCD_Impervious_L48_20190405_full_zip.zip

long_name <- 'NLCD_Impervious_L48_20190405_full_zip'
short_name <- 'impervious'

sg('aws s3 cp s3://mrlc/{long_name}.zip {short_name}.zip')
sg('unzip {short_name}.zip')
sg('rm {short_name}.zip')

glue('gdal_translate -of GTiff NLCD_{yrs}_Impervious_L48_20190405.img impervious_{yrs}.tif') %>%
  walk(system)

glue('gdal_translate -of GTiff NLCD_{yrs}_Impervious_descriptor_L48_20190405.img imperviousdescriptor_{yrs}.tif') %>%
  walk(system)

sg('rm *.xml *.rrd *.rde *.img *.ige')
sg('rm -r NLCD2016_spatial_metadata')

# s3://mrlc/nlcd_2016_treecanopy_2019_08_31.zip

long_name <- 'nlcd_2016_treecanopy_2019_08_31'
short_name <- 'treecanopy_2016'

sg('aws s3 cp s3://mrlc/{long_name}.zip {short_name}.zip')
sg('unzip {short_name}.zip')
sg('rm {short_name}.zip')

sg('gdal_translate -of GTiff {long_name}.img {short_name}.tif')

sg('rm *.xml nlcd_*.html *.img *.ige')

# s3://mrlc/nlcd_2011_treecanopy_2019_08_31.zip

long_name <- 'nlcd_2011_treecanopy_2019_08_31'
short_name <- 'treecanopy_2011'

sg('aws s3 cp s3://mrlc/{long_name}.zip {short_name}.zip')
sg('unzip {short_name}.zip')
sg('rm {short_name}.zip')

sg('gdal_translate -of GTiff {long_name}.img {short_name}.tif')

sg('rm *.xml nlcd_*.html *.img *.ige')
