library(tidyverse)
library(raster)
library(sf)

# 1. Reading to spatial data ----------------------------------------------
ptos <- st_read("Puntos para extracción de datos.kmz") %>% 
  dplyr::select(Name)
# tmax
tmax <- brick("Tmax.nc")
names(tmax) <- seq(as.Date("1960-01-01"),by  = "1 month", length = 432)
# tmin
tmin <- brick("Tmin.nc")
names(tmin) <- seq(as.Date("1960-01-01"),by  = "1 month", length = 432)
anios <- seq(as.Date("1960-01-01"),by  = "1 month", length = 432)
# 2. Extracting pisco data in dots ----------------------------------------
variable <- tmax        # Selection of varible
name_variable <- "tmax" # Change the name of variable
lista <- list()
for (i in 1:length(names(tmax))) {
  data <- extract(variable[[i]], ptos,sp = T) %>% 
    st_as_sf()
  final <- data %>% 
    mutate(year = anios[i]) %>% 
    rename_at(.vars = vars(starts_with("X")),.funs = ~ paste0("value",gsub(".","",.)))
  lista[[i]] <- final
}

final_data <- lista %>% bind_rows() %>% 
  spread(year,value)
# Save spatial data en geopackages format
write_sf(final_data,sprintf("%s.gpkg",name_variable))
