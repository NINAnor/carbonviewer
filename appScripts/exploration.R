library(tidyverse)
library(data.table)

devtools::install_github("Appsilon/shiny.i18n")

webshot::install_phantomjs()

df_read <- fread("/home/rstudio/app/for_calculator_20221010.csv",
                 sep = ";",
                 encoding = "unknown")

df_num <- df_read %>% 
  mutate(perc_SOM = as.numeric(`% SOM`)) %>% 
  mutate(BD = as.numeric(`BD (t/m3)`)) %>% 
  dplyr::select(`SAMPLE ID2`, perc_SOM, BD) %>% 
  group_by(`SAMPLE ID2`) %>% 
  summarise(across(.fns = list(mean =~ mean(., na.rm=TRUE))))

df_info <- df_read %>% 
  dplyr::select(`SAMPLE ID2`, `General Peatland Type`, `Specific Peatland Type`) %>% 
  group_by(`SAMPLE ID2`) %>% 
  unique()

df = full_join(df_num, df_info, by = "SAMPLE ID2") %>% drop_na()


?summarise

df$`BD (t/m3)`

target = c("raised bog", "oceanic bog")

df_sub <- df %>% filter(`Specific Peatland Type` %in% target)
table(df_sub$`Specific Peatland Type`)

########################################
# EXPERIMENT FOR RETURNING THE DATASET #
########################################

shp <- readOGR("/home/rstudio/app/data_exple/Marte/geilo-dybdef.shp")
proj4string(shp) <- crs("+init=epsg:25832")

df <- read.csv2("/home/rstudio/app/data_exple/Marte/torvdybder.csv") 
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

withProgress(message = "Computing the interpolation", {
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

Description <- c("mean", "min", "max", "SD", "max")
results_volume <- data.frame(Description, Results = c(mean, min, max, sd, s)) 

interpolation <- idw(Dybde ~ 1, dfsp, grid_crop, nmax=30, idp=3)
interpolation <- raster(interpolation)




volume




