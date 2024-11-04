library(osmdata)
library(sf)


comarques <- st_read("data_web/comarques.json")
comarques <- st_transform(comarques, "EPSG:25831")
nomcoms <- unique(comarques$NOMCOMAR)


get_length_osm <- function(comarca){
  water_i <- getbb(comarca, format_out = "osm_type_id", viewbox = c(0.16, 40.53, 3.4, 42.9)) |> 
    opq() |> 
    add_osm_features(list("waterway" = "river",
                          "waterway" = "ditch",
                          "waterway" = "stream",
                          "waterway" = "drain",
                          "waterway" = "canal")) |> 
    osmdata_sf()
  
  
  water_i <- rbind(water_i$osm_lines[,"osm_id"], water_i$osm_multilines[,"osm_id"])
  
  water_i <- st_transform(water_i, "EPSG:25831")
  
  water_i <- st_intersection(st_make_valid(water_i), st_make_valid(comarques[comarques$NOMCOMAR == comarca,c("NOMCOMAR")]))
  
  ls <- as.numeric(st_length(water_i$geometry))
  return(sum(ls))
}


lengths_osm <- lapply(nomcoms, get_length_osm)



lengths_osm <- data.frame("NOMCOMAR" = nomcoms,
                          "length_osm" = as.numeric(lengths_osm))


# generate full sf object for quarto


load("data_web/distances_igcg.rda")

comarques_web <- comarques[,"NOMCOMAR"] |> 
  merge(lengths_osm) |> 
  merge(water_comarques_distance) |> 
  st_as_sf()


colnames(comarques_web) <- c("comarca", "length_osm", "length_icgc", "geometry")
comarques_web$ratio <- comarques_web$length_osm/comarques_web$length_icgc
st_write(comarques_web, "data_web/data_quarto.gpkg", append = FALSE)


