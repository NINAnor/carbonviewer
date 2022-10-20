#######################################
# DO THE INTERPOLATION OF THE DATASET #
#######################################

interpolation <- function(BASE){
  
  shp_file <- list.files(BASE, pattern = '.shp', recursive = TRUE)
  csv_file <- list.files(BASE, pattern = '.csv', recursive = TRUE)
  
  shp <- readOGR(paste0(BASE, "/", shp_file))
  proj4string(shp) <- crs("+init=epsg:25832")
  
  df <- read.csv2(paste0(BASE, "/", csv_file)) 
  dfs <- st_as_sf(x = df,
                  coords = c("x", "y"),
                  crs = "+init=epsg:25832")
  sf_shp <- shp %>% st_as_sf()
  dfsp <- as(dfs, Class="Spatial")
  
  #################
  # Interpolation #
  #################
  grid <- raster(extent(shp)) 
  res(grid) <- 1 
  proj4string(grid)<-crs(dfs) 
  grid_sp <-as(grid, "SpatialPixels") 
  grid_crop <- grid_sp[shp,] 
  
  neighbors = length(dfsp$Dybde)
  power = c((0.5), seq(from = 1, to = 4, by = 1))
  neigh = c((1), seq(from=2,to=30,by = 2), c(length=(neighbors)))
  
  temp <- data.frame()
  
  withProgress(message = i18n$t("Beregn volum"), {
    for (i in power) {
      for (j in neigh) {
        
        temp2 <- NULL
        temp3 <- NULL
        temp4 <- NULL
        
        run = paste(i, j, sep="_")
        
        temp2 <- idw(Dybde ~ 1, dfsp, grid_crop, nmax=j, idp=i)
        temp3 <- as.data.frame(temp2@data)
        temp4 <- sum(temp3$var1.pred)
        temp5 <- cbind(run, temp4)
        temp  <- rbind(temp, temp5)
      }
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
  
  interpolation <- idw(Dybde ~ 1, dfsp, grid_crop, nmax=30, idp=3)
  interpolation <- raster(interpolation)
  
  # Return the interpolation and the result volume
  l_results <- list(results_volume, interpolation)
  return(l_results)
}








