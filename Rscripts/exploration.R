library(tidyverse)
library(data.table)
library(gstat)

# Define file paths
shapefile_path <- "/home/rstudio/app/data_exple/test_dataset/test_shapefile.shp"
csv_path <- "/home/rstudio/app/data_exple/test_dataset/test_depths_samples.csv"

# Read shapefile and convert to simple features object
shp <- rgdal::readOGR(shapefile_path) %>% 
  sf::st_as_sf()

input_crs = st_crs(shp)
target_crs = 25833

# Read CSV data
df <- open_csv(csv_path)

# Transform CSV data to spatial format and set its CRS to match the shapefile
dfs <- transform_to_sf(df) %>% 
  sf::st_set_crs(sf::st_crs(input_crs))

# Transform both datasets to the target CRS
dfs <- dfs %>% sf::st_transform(target_crs)
shp <- shp %>% sf::st_transform(target_crs)

myGrid <- starsExtra::make_grid(shp, 1)
myGrid <- sf::st_crop(myGrid, shp)

powerRange <- 1:6
nmax <- 20
temp <- data.frame(power = powerRange, MAE = rep(NA, length(powerRange)))
vol <- numeric()

# Calc. the Volume for kriging and IDW with different power values
# Cross-validation used to calc. MAE and optimal power value
# Optimal power value is used to calc the volume


# Final interpolation and volume calc using optimal power value
for(i in 2){
  
  # Get the MAE
  temp2 <- gstat::krige.cv(torvdybde_cm ~ 1, dfs, set = list(idp=i), nmax = nmax)
  temp$MAE[temp$power==i] <- mean(abs(temp2$residual))
  
  #  Get the volume in cm3 
  vol_temp <- gstat::idw(torvdybde_cm ~ 1, dfs, 
                         newdata=myGrid, 
                         nmax=nmax, 
                         idp=i)
  # vol in m3
  vol <- c(vol, sum(vol_temp$var1.pred, na.rm=T))
  vol_m3 <- vol/100

}

idwe <- gstat::idw(formula = torvdybde_cm ~ 1, 
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
            title = "Torvdybde (cm)") %>% 
  #addControl("title", position = "topleft", className="map-title")

leaflet() %>% addTiles() %>%
  addRasterImage(idwe_r, colors = pal) #%>% 
  #addLegend(pal = pal, values = values(idwe_r),
  #          title = "torvdybde_cm") %>% 
  #addControl(title, position = "topleft", className="map-title")


