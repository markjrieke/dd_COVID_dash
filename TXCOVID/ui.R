# libraries ----
library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(leaflet)
library(shinythemes)

# setup ----
f_pop <- as_tibble(read.csv("data/county_names.csv"))

l_counties <- split(f_pop$variable, f_pop$county)

rm(f_pop)

license_text <- p(style = "text-align: right",
                  "Data from the New York Times, based on reports from state and
                  local health agencies.")

# ui ----
shinyUI(
    bootstrapPage(
        navbarPage(
            "Texas COVID-19 Dashboard",
            theme = shinytheme("sandstone"),
            collapsible = TRUE,
            
            tabPanel(
                "State Information",
                
                sidebarPanel(
                  
                  # Info to display
                  radioButtons("input_count", "Compare:",
                               list("Cases" = "cases",
                                    "Deaths" = "deaths")),
                  
                  # Plot type
                  radioButtons("input_type", "Time Period:",
                               list("14-day average" = "avg",
                                    "Cumulative" = "cum")),
                  
                  br(),
                  
                  # Total or per 100,000
                  radioButtons("input_scale", NULL,
                               list("Per 100,000" = "norm",
                                    "Total" = "abs")),
                  
                  sliderInput("input_bubble", "Bubble Size:",
                              min = 0,
                              max = 50,
                              value = 25,
                              step = 1)
                  
                  
                ),
                
                mainPanel(
                  tabsetPanel(
                    tabPanel(
                      "Map",
                      tags$h4(
                        tags$b("COVID-19 in Texas")
                      ),
                      h5(textOutput("text_state_map")),
                      leafletOutput("map_leaflet"),
                      license_text
                    ),
                    
                    tabPanel(
                      "State Data",
                      tags$h4(
                        tags$b("COVID-19 in Texas")
                      ),
                      h5(textOutput("text_state_line")),
                      plotlyOutput("state_lineplot"),
                      license_text
                    ),
                    
                    tabPanel(
                      "Log-Log Plot",
                      # htmlOutput("text_state"),
                      p("Log-Log plot coming soon.")
                    )
                  )
                )
            ),
            
            tabPanel(
                "County Comparison",
                
                sidebarPanel(
                    
                    # Information to display
                    radioButtons("count_var", "Compare:",
                                 list("Cases" = "cases",
                                      "Deaths" = "deaths")),
                    
                    # Plot type:
                    radioButtons("count_type", "Time Period:",
                                 list("14-day average" = "avg",
                                      "Cumulative" = "cum")),
                    
                    br(),
                    
                    # Total or per 100,000
                    radioButtons("count_scale", NULL,
                                 list("Per 100,000" = "norm",
                                      "Total" = "abs")),
                    
                    # Select county
                    selectInput("county1", "Compare up to 3 counties:",
                                l_counties,
                                selected = l_counties[215]),
                    
                    selectInput("county2", NULL,
                                l_counties,
                                selected = l_counties[57]),
                    
                    selectInput("county3", NULL,
                                l_counties,
                                selected = l_counties[101])
                ),
                
                mainPanel(
                    plotlyOutput("lineplot"),
                    license_text
                )
            ),
            
            tabPanel(
              "About",
              h3("About"),
              hr(),
              p(style = "text-align: justify;",
                "This site serves as a supplement to the ",
                tags$a(href = "https://txdshs.maps.arcgis.com/apps/opsdashboard/index.html#/ed483ecd702b4298ab01e8b9cafc8b83",
                       "Texas State Health Department Dashboard"),
                " and the ",
                tags$a(href = "https://www.nytimes.com/interactive/2020/us/texas-coronavirus-cases.html",
                       "New York Times Texas COVID Tracker."),
                " Both the State Health Department and the New York Times 
                dashboards offer ",
                tags$i("live"),
                " county data and ",
                tags$i("historical"),
                " state data, but neither offer ",
                tags$i("historical county data."),
                " The goal of this site is to complement these resources with 
                historical Texas county data while introducing a few interactive 
                features that allow users to explore the data."),
              br(),
              p(style = "text-align: justify;",
                "This site uses data from ",
                tags$a(href = "https://github.com/nytimes/covid-19-data",
                       "the New York Times COVID database"),
                " - you can read the ",
                tags$a(href = "https://github.com/nytimes/covid-19-data/blob/master/LICENSE",
                       "LICENSE"),
                " for the full terms of use of their data."),
              h3("Contact"),
              hr(),
              p(style = "text-align: justify;",
                "If you notice an error, have questions about the site/data, or 
                would like to request a specific feature, you can reach out to 
                me via email:"),
              br(),
              p(tags$a(href = "mailto:markjrieke@gmail.com",
                       "markjrieke@gmail.com"))
            )
        )
    )
)
