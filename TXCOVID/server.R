# libraries ----
library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)

# setup ----

f_counties <- as_tibble(read.csv("data/county_data.csv"))
f_counties %>%
    select(-X)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    # output line plot
    output$lineplot <- renderPlotly({

        f_counties %>%
            filter(county == input$county) %>%
            ggplot(aes(x = date,
                       y = cases)) +
            geom_path(group = 1)
        
    })
    
    # table render...
    output$table <- renderTable({
        
        f_counties %>%
            filter(county == input$county)
        
    })

})
