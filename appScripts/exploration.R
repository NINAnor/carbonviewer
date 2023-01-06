library(tidyverse)
library(data.table)

devtools::install_github("Appsilon/shiny.i18n")


df_read <- fread("/home/rstudio/app/dataset.csv",
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


tm_shape(shp) + 
  tm_polygons() +
tm_shape(dfs) +
  tm_dots() +
tm_layout(title= 'Map of the sampled area')

  

plot(shp)
plot(dfs)

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
} 

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

tm_shape(interpolation) +
  tm_raster(title = "Depth") +
  tm_layout(title= 'Map of the interpolated area',
            legend.position = c("left", "top"))


###################
# REPROJECT TYDAL #
###################
library(sf)

shp <- readOGR("/home/rstudio/app/data_exple/Tydal/stasjon_Setermyra.shp") %>% st_as_sf()
shp_reproj <- shp %>% st_transform(25832)

df <- read.csv2("/home/rstudio/app/data_exple/Tydal/Torvdybder_Tydal.csv") 
dfs <- st_as_sf(x = df,
                coords = c("x", "y"))
dfs_reproj <- dfs %>% st_transform(25832)


st_write(shp_reproj, "/home/rstudio/app/data_exple/test_shapefile.shp")
st_write(dfs_reproj, "/home/rstudio/app/data_exple/test_dataset/test_depths_samples.csv",
         layer_options = "GEOMETRY=AS_XY")


mapview(dfs)



st_crs(shp)
st_crs(25832)


st


coor <- data.frame(a = c("x", "X"), b = c("y", "Y"))

for( cols in 1:length(coor)){
  a = as.vector(unlist(coor[cols,]))

}
a
as.vector(unlist(a[1]))
a[1]

fread()



#create data frame
df <- data.frame(x=c(99, 90, 86, 88, 95),
                 y=c(33, 28, 31, 39, 34),
                 Dybde=c(30, 28, 24, 24, 28),
                 a=c(1,1,1,1,1))

#view data frame
names(df) <- tolower(names(df))
df
columns <- c("x", "y", "dybde")

sum(tolower(names(df)) %in% columns )

