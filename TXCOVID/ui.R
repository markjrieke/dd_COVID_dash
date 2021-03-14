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
    pageWithSidebar(
        
        # App title
        headerPanel("Texas COVID Dashboard"),
        
        sidebarPanel(
            
            # Information to display:
            radioButtons("view", "View:",
                         list("Confirmed cases" = "cases",
                              "Confirmed deaths" = "deaths")),
            # Plot Type:
            radioButtons("type", "Plot Type:",
                         list("Biweekly average" = "avg",
                              "Cumulative" = "cum")),
            # Select County
            selectInput("county", "County:",
                        l_counties,
                        selected = l_counties[215])
        ),
        mainPanel(
            plotlyOutput("lineplot"),
            tableOutput("table")
        )
    )
)
