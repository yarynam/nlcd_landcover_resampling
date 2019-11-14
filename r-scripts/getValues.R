library(raster)
library(rgdal)

### based on https://gis.stackexchange.com/questions/130522/increasing-speed-of-crop-mask-extract-raster-by-many-polygons-in-r

mosaic_100 <- raster("mosaics/mosaic_rsmpl_100m.tif") #load raster
shp <- readOGR("drought-0813", "USDM_20180807_OBJECTID_3") #load shapefile
shp_conic <- spTransform(shp, crs(mosaic_100)) #reproject

clip1 <- crop(mosaic_100, extent(shp_conic)) #crop to extent of polygon
clip2 <- rasterize(shp_conic, clip1, mask=TRUE) #crops to polygon edge & converts to raster
ext <- getValues(clip2) #much faster than extract
ext_simp <- ext[!is.na(ext)] #remove NA values
tab <- table(ext_simp) #tabulates the values of the raster in the polygon
tab_clip_df <- data.frame(tab)
write.csv(tab_clip_df,"stats/clipped_mosaic_3.csv", row.names=FALSE)
