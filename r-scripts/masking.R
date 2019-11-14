library(raster)
library(rgdal)

mosaic_2011 <- raster("nlcd_analysis/mosaic_rsmpl_100m.tif")
mosaic_2011


dir <- "USDM_current_M/splited"
files <- list.files(path=dir, pattern="*.shp", full.names=TRUE, recursive=FALSE)

lapply(files, function(x) {
  name <- gsub(dir, "", x)
  name <- gsub(".shp", "", name)
  name <- gsub("/", "", name)
  number <- gsub("USDM_20180731_OBJECTID_", "", name)
  clpd_name <- paste("nlcd_analysis/mosaic_masked_", number, ".tif", sep = "")
  stat_clpd_name <- paste( "nlcd_analysis/mosaic_masked_stat_", number, ".csv", sep = "")
  stat_clpd_name

  shp <- readOGR(dir, name)
  shp_conic <- spTransform(shp, crs(mosaic_2011))
  mosaic_clipped <- mask(mosaic_2011, shp_conic)
  writeRaster(mosaic_2011_clipped, filename=clpd_name, format='GTiff', overwrite=TRUE)

  clip_df <- data.frame(freq(mosaic_clipped)) #get pixel count within masked area
  write.csv(clip1_df, stat_clpd_name)
})
