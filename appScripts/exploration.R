library(tidyverse)
library(data.table)
library(gstat)

shp <- readOGR("/home/rstudio/app/data_exple/test_dataset/test_shapefile.shp") %>% st_as_sf()
df <- open_csv("/home/rstudio/app/data_exple/test_dataset/test_depths_samples.csv") 

# Transform CRS
dfs <- transform_to_sf(df) %>% st_set_crs(st_crs(shp))
dfs <- dfs %>% st_transform(25832)
shp <- shp %>% st_transform(25832)

myGrid <- starsExtra::make_grid(shp, 1)
myGrid <- sf::st_crop(myGrid, shp)

powerRange <- 1:6
nmax <- 20

for(i in powerRange){
  
  # Get the MAE
  temp2 <- gstat::krige.cv(Dybde ~ 1, dfs, set = list(idp=i), nmax = nmax)
  temp$MAE[temp$power==i] <- mean(abs(temp2$residual))
  
  #  Get the volume
  vol_temp <- gstat::idw(dybde ~ 1, dfs, 
                         newdata=myGrid, 
                         nmax=nmax, 
                         idp=i)
  
  vol <- c(vol, sum(vol_temp$var1.pred, na.rm=T))
}

idwe <- gstat::idw(formula = Dybde ~ 1, 
                        locations = dfs, 
                        newdata = myGrid, 
                        idp=4,
                        nmax = nmax)


idwe_r <- as(idwe, "Raster")

library(leafem)

pal = colorNumeric(palette = "magma", 
                   values(idwe_r),  na.color = "transparent",
                   reverse = TRUE)

leaflet() %>% addTiles() %>%
  addStarsImage(idwe, colors = pal) %>% 
  addLegend(pal = pal, values = values(idwe_r),
            title = "Dybde") %>% 
  addControl("title", position = "topleft", className="map-title")


leaflet() %>% addTiles() %>%
  addRasterImage(idwe_r, colors = pal) #%>% 
  #addLegend(pal = pal, values = values(idwe_r),
  #          title = "Dybde") %>% 
  #addControl(title, position = "topleft", className="map-title")


