# libraries ----
library(dplyr)
library(zoo)
library(readr)
library(stringr)
library(ggplot2)

# data import ----

# COVID data from NYT
f_counties <- read_csv(
  "https://github.com/nytimes/covid-19-data/raw/master/us-counties.csv"
)
    

# population data from TX demographics site
f_pop <- read_csv(
  "https://demographics.texas.gov/Resources/TPEPP/Estimates/2019/2019_txpopest_county.csv"
)

# data wrangling ----

# county population wrangling
f_pop <- f_pop %>%
  select(county, jan1_2020_pop_est)

# col rename for brevity
colnames(f_pop) <- c("county", "pop")

# county frame setup 
f_counties <- f_counties %>%
  filter(state == "Texas") %>%
  select(-state, -fips) %>%
  mutate(date = as.Date(date))

# Getting TX state totals in the right format 
f_texas <- f_counties %>%
  arrange(date) %>%
  group_by(date) %>%
  mutate(cases = sum(cases),
         deaths = sum(deaths)) %>%
  ungroup() %>%
  distinct(date, .keep_all = TRUE) %>%
  mutate(county = "State of Texas")

f_counties <- rbind(f_counties, f_texas)
rm(f_texas)

# TX state
f_counties <- f_counties %>%
  arrange(date) %>%
  mutate(county = str_replace(county, "DeWitt", "De Witt")) %>%
  group_by(county) %>%
  mutate(new_cases = cases - lag(cases),
          new_deaths = deaths - lag(deaths),
          avg_cases = rollmean(new_cases, 14, align = "right", fill = NA),
          avg_deaths = rollmean(new_deaths, 14, align = "right", fill = NA)) %>%
  left_join(f_pop, by = "county") %>%
  mutate(cases_norm = cases/pop * 100000,
         deaths_norm = deaths/pop * 100000,
         avg_cases_norm = avg_cases/pop * 100000,
         avg_deaths_norm = avg_deaths/pop * 100000) %>%
  select(-new_cases, -new_deaths, -pop)

# add in lat/long ----
f_map <- as_tibble(map_data("county")) %>%
  filter(region == "texas") %>%
  group_by(subregion) %>%
  mutate(avg_lat = mean(lat),
         avg_long = mean(long)) %>%
  ungroup() %>%
  select(subregion, avg_lat, avg_long) %>%
  distinct(subregion, .keep_all = TRUE)

f_counties <- f_counties %>%
  mutate(lookup = tolower(county)) %>%
  left_join(f_map, by = c("lookup" = "subregion")) %>%
  select(-lookup)

# create list for ui ----
f_pop <- f_pop %>%
  select(county) %>%
  filter(county != "State of Texas") %>%
  arrange(county)

# create a temp tibble to order correctly
f_temp <- as_tibble("State of Texas")

colnames(f_temp) <- "county"

f_pop <- rbind(f_temp, f_pop)

rm(f_temp)

# create list of county names to be loaded
f_pop <- f_pop %>%
  mutate(variable = county)

# export & save to data folder ----
write.csv(f_counties, 
          "TXCOVID/data/county_data.csv")

write.csv(f_pop,
          "TXCOVID/data/county_names.csv")

# test area ----


# hi!
