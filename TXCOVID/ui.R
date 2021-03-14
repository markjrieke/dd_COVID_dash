# libraries ----
library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)

# setup ----
f_pop <- as_tibble(read.csv("data/county_names.csv"))

l_counties <- split(f_pop$variable, f_pop$county)

rm(f_pop)

# ui ----
shinyUI(
    fluidPage(
        
        # App title
        headerPanel("Texas COVID Dashboard"),
        
        sidebarPanel(
            
            # Information to display:
            radioButtons("count_var", "View:",
                         list("Confirmed cases" = "cases",
                              "Confirmed deaths" = "deaths")),
            # Plot Type:
            radioButtons("count_type", "Plot Type:",
                         list("Biweekly average" = "avg",
                              "Cumulative" = "cum")),
            
            br(),
            
            # Total or per 100,000
            radioButtons("count_scale", NULL,
                         list("Total" = "abs",
                              "Per 100,000" = "norm")),
            
            # Select County
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
    )
)
