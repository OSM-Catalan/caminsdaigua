library(osmdata)
library(sf)

comarques <- st_read("data_web/comarques.json")
comarques <- st_transform(comarques, "EPSG:25831")
nomcoms <- unique(comarques$NOMCOMAR)
nomcoms <- sort(nomcoms)
# download osm ids for all comarques
print("starting to get Comarca ids")
cids <- getbb("Catalonia", format_out = "osm_type_id") |>
  opq(osm_types = "rel",
      out = "tags") |>
  add_osm_feature("admin_level", "7") |>
  osmdata_data_frame()

cids$name[cids$name == "la Selva"] <- "Selva"

cids <- cids[cids$name %in% nomcoms, c("osm_id", "name")]

cids <- cids[order(cids$name), ]

get_length_osm <- function(comarca, id) {
  water_i <- opq(paste0("relation(id:", id, ")")) |>
    add_osm_features(list("waterway" = "river",
                          "waterway" = "ditch",
                          "waterway" = "stream",
                          "waterway" = "drain",
                          "waterway" = "canal")) |>
    osmdata_sf()


  water_i <- rbind(water_i$osm_lines[, "osm_id"],
                   water_i$osm_multilines[, "osm_id"])

  water_i <- st_make_valid(st_transform(water_i, "EPSG:25831"))

  com <- st_make_valid(comarques[comarques$NOMCOMAR == comarca,
                                 c("NOMCOMAR")])
  water_i <- st_intersection(water_i,
                             com)

  ls <- as.numeric(st_length(water_i$geometry))
  return(sum(ls))
  print(paste(comarca, "done"))
}


print("starting to get Comarca waterway lengths")
lengths_osm <- mapply(get_length_osm,
                      cids$name, cids$osm_id)


print("Comarca waterway lengths downloaded")
lengths_osm <- data.frame("NOMCOMAR" = cids$name,
                          "length_osm" = as.numeric(lengths_osm))


# generate full sf object for quarto


load("data_web/distances_igcg.rda")

comarques_web <- comarques[, "NOMCOMAR"] |>
  merge(lengths_osm) |>
  merge(water_comarques_distance) |>
  st_as_sf()


colnames(comarques_web) <- c("comarca", "length_osm", "length_icgc", "geometry")
comarques_web$ratio <- comarques_web$length_osm / comarques_web$length_icgc
st_write(comarques_web, "data_web/data_quarto.gpkg", append = FALSE)
