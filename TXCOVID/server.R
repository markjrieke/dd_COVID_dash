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
            filter(county %in% c(input$county1,
                                 input$county2,
                                 input$county3)) %>%
            ggplot(aes(x = date,
                       y = cases_norm,
                       color = county)) +
            geom_path(group = 1) +
            labs(title = paste("COVID-19 in Texas<br>Comparing Cases per 100,000 in ",
                               input$county1,
                               ", ",
                               input$county2,
                               ", and ",
                               input$county3,
                               ".",
                               sep = ""),
                 subtitle = paste("Comparing Cases per 100,000 in",
                                  input$county1,
                                  input$county2,
                                  input$county3,
                                  ssep = " "))
        
    })
    
    # table render...
    output$table <- renderTable({
        
        f_counties %>%
            filter(county %in% c(input$county1,
                                 input$county2,
                                 input$county3))
        
    })

})
