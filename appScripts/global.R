#######################################
# DO THE INTERPOLATION OF THE DATASET #
#######################################

interpolation <- function(shp, dfsp){
  grid <- raster(extent(shp)) 
  res(grid) <- 1 
  proj4string(grid)<-crs(dfsp) 
  grid_sp <-as(grid, "SpatialPixels") 
  grid_crop <- grid_sp[shp,] 
  
  neighbors = length(dfsp$dybde)
  power = c((0.5), seq(from = 1, to = 4, by = 1))
  neigh = 30 
  
  temp <- data.frame()
  
  withProgress(message = i18n$t("Beregn volum"), {
    for (i in power) {
        
        temp2 <- NULL
        temp3 <- NULL
        temp4 <- NULL
        
        run = paste(i, sep="_")
        
        temp2 <- idw(dybde ~ 1, dfsp, grid_crop, nmax=neigh, idp=i)
        temp3 <- as.data.frame(temp2@data)
        temp4 <- sum(temp3$var1.pred)
        temp5 <- cbind(run, temp4)
        temp  <- rbind(temp, temp5)

      Sys.sleep(0.5)
      incProgress(1 / length(power))
    } 
  })
  
  volume <- temp
  volume <-dplyr::rename(volume, volume=temp4)
  volume <- tidyr::separate(volume, 
                            run, 
                            into = c("power", "nn"),
                            sep = "_",
                            remove=F)
  volume$power <- as.numeric(volume$power)
  volume$nn <- as.numeric(volume$nn)
  volume$volume <- as.numeric(volume$volume)
  
  s <- sum(volume$volume)
  max <- max(volume$volume)
  min <- min(volume$volume)
  mean <- mean(volume$volume)
  sd <- sd(volume$volume)
  
  Description <- c("mean", "min", "max", "SD", "sum")
  results_volume <- data.frame(Description, Results = c(mean, min, max, sd, s)) 
  
  interpolation <- idw(dybde ~ 1, dfsp, grid_crop, nmax=30, idp=3)
  interpolation <- raster(interpolation)
  
  # Return the interpolation and the result volume
  l_results <- list(results_volume, interpolation)
  return(l_results)
}

#######################
# SOME ERROR HANDLING #
#######################

# Error message when checking if the .zip file contain the necessary files
print_no_shp <- function(){
  showModal(modalDialog(
    title = "SHP input error",
    "The uploaded .zip file does not contain any .shp file",
    easyClose = TRUE
  ))
}

print_no_prj <- function(){
  showModal(modalDialog(
    title = "SHP input error",
    "The uploaded .zip file does not contain any .prj file containing the 
    information on the Coordinate Reference System",
    easyClose = TRUE
  ))
}

print_no_csv <- function(){
  showModal(modalDialog(
    title = "CSV input error",
    "The uploaded .zip file does not contain any .csv file containing the coordinates and the depth of the sampled sites",
    easyClose = TRUE
  ))
}

print_error_incompatible_file <- function(){
  showModal(modalDialog(
    title = "Input error",
    "Please upload a dataset before clicking on 'load dataset'. 
          The dataset should be a zip file containing both a shapefile with the 
          extent of the area of interest and a csv file containing peat depth measures 
          (in m) taken at the site with coordinates for each measure (given in UTM 32 N, EPSG:25832). 
          For more information refer to the README.",
    easyClose = TRUE
  ))
}

print_error_csv_columns <- function(){
  showModal(modalDialog(
    title = "CSV input error",
    "The CSV file uploaded is not formatted correctly. Please make sure that it contains at least 
    the coordinates (x and y) and the depth of the sampled sites (dybde). In any doubts, refer to the README.",
    easyClose = TRUE
  ))
}


# Error message if files are not opened properly

open_shapefile <- function(filename){
  
    shp <- readOGR(filename) %>% st_as_sf()
    
    if (length(shp) == 0){
      showModal(modalDialog(
        title = "SHP input error",
        "The SHP file uploaded is invalid. Please make sure that it contains the polygon(s) of the area of interest. 
            In any doubts, refer to the README.",
        easyClose = TRUE
      ))
    }
    else {
      return(shp)
    }
}

open_csv <- function(filename) {
  tryCatch({
      df <- fread(filename)
      return(df)
    }, error = function(e) {})
  stop("Could not open the file")
}


transform_to_sf <- function(df) {
  coord_columns <- list(c("X", "Y"), c("x", "y"))
  for (cols in coord_columns) {
    tryCatch({
      sf_df <- st_as_sf(df, coords = cols)
      return(sf_df)
    }, error = function(e) {})
  }
  stop("Could not transform the file with any of the following coordinates: ", cols)
}







