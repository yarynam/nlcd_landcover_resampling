library(raster)
library(rgdal)

dir <- "nlcd_2011_landcover_2011_edition_2014_10_10/tiles"
files <- list.files(path=dir, pattern="*.tif", full.names=TRUE, recursive=FALSE) #list of tiles
lapply(files, function(x) {
  r <- raster(x) # load file
  rsmpl_nrow <- round(dim(r)[1]*30/100) #number of cells for 100m resolution
  rsmpl_ncol <- round(dim(r)[2]*30/100)

  name <- gsub(dir, "", x)
  name <- gsub(".tif", "", name)
  rsmpl_name <- paste( dir, "/resampled", name, "_100m.tif", sep = "")

  s <- raster(nrow=rsmpl_nrow, ncol=rsmpl_ncol) #make "canvas" raster where resampled pixels will be drawn
  extent(s) <- extent(r) #copy extent
  proj4string(s) <- CRS(r) #define projection

  r_rsmpl <- resample(r, s, method='ngb') #resample
  writeRaster(r_rsmpl, filename=rsmpl_name, format='GTiff', overwrite=TRUE) #write to file
  r_rsmpl #print resampled meta data
})
