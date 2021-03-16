# Leaflet practice

# libraries ----
library(maps)
library(leaflet)

# getting lat/long position for each county

as_tibble(map_data("county")) %>%
  filter(region == "texas") %>%
  select(long, lat, subregion) %>%
  group_by(subregion) %>%
  mutate(avg_long = mean(long)) %>%
  mutate(avg_lat = mean(lat)) %>%
  ungroup() %>%
  select(subregion, avg_long, avg_lat) %>%
  dplyr::distinct(subregion, .keep_all = TRUE)


f_counties <- f_counties %>%
  filter(date == max(date)) %>%
  select(-county_lower)

tooltip_text <- paste(
  "<b>County:</b> ", f_counties$county, "<br/>",
  "<b>Cases:</b> ", comma(f_counties$cases, accuracy = 1),"<br/>",
  "<b>Deaths:</b> ", comma(f_counties$deaths, accuracy = 1),
  sep = ""
) %>%
  lapply(htmltools::HTML)

leaflet(f_counties) %>%
  addTiles() %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addCircleMarkers(
    ~avg_long,
    ~avg_lat,
    fillColor = "red",
    fillOpacity = 0.5,
    color = "red",
    stroke = FALSE,
    radius = ~sqrt(cases/max(cases))*100,
    label = tooltip_text,
    labelOptions = labelOptions(style = list("font-weight" = "normal",
                                             padding = "3px 8px"),
                                textsize = "13px",
                                direction = "auto")
  )


# create dataframe of avg long/lat points
f_position <- as_tibble(map_data("county")) %>%
  filter(region == "texas") %>%
  select(long, lat, subregion) %>%
  group_by(subregion) %>%
  mutate(avg_long = mean(long)) %>%
  mutate(avg_lat = mean(lat)) %>%
  ungroup() %>%
  select(subregion, avg_long, avg_lat) %>%
  dplyr::distinct(subregion, .keep_all = TRUE)

# add to county dataframe & unload from memory
f_counties <- f_counties %>%
  mutate(date = as.Date(date),
         county_lower = tolower(county)) %>%
  left_join(f_position, by = c("county_lower" = "subregion"))

rm(f_position)
