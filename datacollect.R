# libraries ----
library(dplyr)
library(zoo)

# data import ----

# COVID data from NYT
f_counties <- as_tibble(
  read.csv(
    "https://github.com/nytimes/covid-19-data/raw/master/us-counties.csv"
    )
  )

# population data from TX demographics site
f_pop <- as_tibble(
  read.csv(
    "https://demographics.texas.gov/Resources/TPEPP/Estimates/2019/2019_txpopest_county.csv"
    )
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
