# libraries ----
library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(shinythemes)

# setup ----
f_pop <- as_tibble(read.csv("data/county_names.csv"))

l_counties <- split(f_pop$variable, f_pop$county)

rm(f_pop)

# ui ----
shinyUI(
    bootstrapPage(
        navbarPage(
            h3("Texas COVID-19 Dashboard"),
            theme = shinytheme("sandstone"),
            collapsible = TRUE,
            
            tabPanel(
                h4("State Information"),
                
                tabsetPanel(
                    tabPanel(
                        h4("Map"),
                        h4("Leaflet plot coming soon")
                    ),
                    
                    tabPanel(
                        h4("State Data"),
                        h4("Plotly plot coming soon")
                    ),
                    
                    tabPanel(
                        h4("Log-Log Plot"),
                        h4("Log-Log Plot coming soon")
                    )
                )
            ),
            
            tabPanel(
                h4("County Comparison"),
                
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
                    plotlyOutput("lineplot")
                )
            ),
            
            tabPanel(
                h4("About"),
                h4("About section coming soon")
            )
        )
    )
)
