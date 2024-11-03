library(sf)
library(tidyverse)

# clean and prepare data
# data was in my home directory, can be provided by request, not uploading because it would weigh down the repo too badly.
water <- st_read("~/aigua_icgc.gpkg") # downloaded w/ qgis from https://sig.gencat.cat/ows/AIGUA/wfs, layer AIGUA_XARXA_RIUS_ARC

comarques <- st_read("~/Baixades/divisions-administratives-v2r1-comarques-100000-20240705.json")


comarques <- comarques[,c("NOMCOMAR")]
comarques <- st_transform(comarques, st_crs(water))

water_comarques <- st_intersection(st_make_valid(water), st_make_valid(comarques))


water_comarques <- st_transform(water_comarques, "EPSG:4326") # back transform to make it compatible w/ josm


water_comarques$geometry |> st_geometry_type() |> unique()

nomcoms <- unique(comarques$NOMCOMAR)


# save water courses by comarca
for(i in 1:length(nomcoms)){
  water_comarques_i <- water_comarques[water_comarques$NOMCOMAR == nomcoms[i],]
  st_write(water_comarques_i,
           paste0("data_osm/water_courses_", nomcoms[i], ".geojson"))
}




# get sum of water course distances by comarca for app


water_comarques_distance <- water_comarques |> 
  mutate(dist = as.numeric(st_length(geometry))) |> 
  st_drop_geometry() |> 
  summarise(icgc_distance = sum(dist), .by = NOMCOMAR)

save(water_comarques_distance, file = "data_web/distances_igcg.rda")
