# Resampling NLCD land cover classification raster

> 📢 Environment alert: this approach uses QGIS, R and GDAL tools

## STEP 1: Get data
Latest land cover classification can be obtained [here](https://www.mrlc.gov/finddata.php).

## STEP 2: Slice source raster into tiles
2011 land cover classification is a 17 Gb file.😱 Processing it at once is barely possible, unless you have access to a powerful computational cluster. But we can slice it into chunks and process one by one. Here is a detailed [post](https://howtoinqgis.wordpress.com/2016/12/17/how-to-split-a-raster-in-several-tiles-using-qgis-or-python-gdal/) on how to do this. GDAL or QGIS that's you choice, but I personally used QGIS.
1. Load the raster in the Layers Panel;
2. Right-click on it and choose Save As...;
3. Check the Create VRT option;
4. Choose the folder where your outputs will be saved;
5. Set the extent (if you want to work on the whole raster, don’t modify anything);
6. Choose if using the current resolution (I suggest to leave it as default);
7. Set the max number of columns and rows;
8. Press the OK button.


 ## STEP 3: Resample
 Now time for some R magic!🧙‍There are many ways of [resampling raster data](https://gisgeography.com/raster-resampling/), but since we are dealing with categorical data, I decided to go with nearest neighbor algorithm. Luckily, `resample()` method from `raster` package does exactly what we need (`r_rsmpl <- resample(r, s, method='ngb') #resample`). The code is below
 ```
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

 ```
Brace yourself. It will take a while...⏰ Resampling down to 300m per pixel took me a few hours. Resampling to 100m per pixel took 20+ hours, so I recommend starting this script on a Saturday morning and enjoy the rest of your weekend.🚵🏻‍


 ## STEP 4: Put it all together
Great! Now you got your nicely resampled tiles! But chances are you would prefer to work with the entire file rather than tiles. Fear not, you can always make a mosaic! I found these few GDAL commands to be the fastest and the most optimal way to do so.
1. `gdalbuildvrt rsmpl_100m.vrt resampled/*.tif`  Creates a virtual mosaic
2. `gdal_translate -of Gtiff -ot Byte -co COMPRESS=LZW rsmpl_100m.vrt mosaic_rsmpl_300m.tif` Uses LZW compression which preserves original data values, but decreases the size of the output.


 ## STEP 5: Party time!
 Hooray! The initial 17 Gb file with 30m resolution ended up as a 191 Mb file with 100m resolution or 23 Mb file with 300m resolution! 🎉 🎉 🎉  How exciting is that! Now go and perform whatever analysis you want! You can start with masking raster with shapefiles (`r-scripts/masking.R`) or counting pixels by category without generating masks (faster approach here `r-scripts/getValues.R`)
