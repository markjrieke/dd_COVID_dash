# libraries ----
library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(forcats)
library(scales)

# setup ----

devtools::source_url(
    "https://raw.githubusercontent.com/markjrieke/thedatadiary/main/dd_theme_elements/dd_theme_elements.R"
    )

f_counties <- as_tibble(read.csv("data/county_data.csv"))
f_counties %>%
    select(-X) %>%
    mutate(date = as.Date(date))

# server ----
shinyServer(function(input, output) {
    
    
    # output line plot
    output$lineplot <- renderPlotly({
        
        # ooof ready for some ugly code???
        # create 3 col frame
        if (input$count_type == "avg") {
            if (input$count_var == "cases") {
                if (input$count_scale == "norm") {
                    
                    f_plot <- f_counties %>%
                        select(date, county, avg_cases_norm)
                    
                } else { # count_scale == "abs"
                    
                    f_plot <- f_counties %>%
                        select(date, county, avg_cases)
                    
                }
            } else { # count_var == "deaths"
                if (input$count_scale == "norm") {
                    
                    f_plot <- f_counties %>%
                        select(date, county, avg_deaths_norm)
                    
                } else { # count_scale == "abs"
                    
                    f_plot <- f_counties %>%
                        select(date, county, avg_deaths)
                    
                }
            }
        } else { # count_type == "total"
            if (input$count_var == "cases") {
                if (input$count_scale == "norm") {
                    
                    f_plot <- f_counties %>%
                        select(date, county, cases_norm)
                    
                } else { # count_scale == "abs"
                    
                    f_plot <- f_counties %>%
                        select(date, county, cases)
                    
                }
            } else { # count_var == "deaths"
                if (input$count_scale == "norm") {
                    
                    f_plot <- f_counties %>%
                        select(date, county, deaths_norm)
                    
                } else { # count_scale == "abs"
                    
                    f_plot <- f_counties %>%
                        select(date, county, deaths)
                    
                }
            }
        }
        
        colnames(f_plot) <- c("date", "county", "var")

        # create ggplot
        p<- f_plot %>%
            filter(county %in% c(input$county1,
                                 input$county2,
                                 input$county3)) %>%
            mutate(county = fct_relevel(county,
                                        input$county1,
                                        input$county2,
                                        input$county3)) %>%
            ggplot(aes(x = as.Date(date),
                       y = var,
                       color = county,
                       text = paste(county, 
                                    "<br>",
                                    number(var, 
                                           big.mark = ",",
                                           accuracy = 1)))) +
            geom_path(group = 1) +
            scale_color_manual(values = c(dd_blue, 
                                          dd_red, 
                                          dd_green)) +
            labs(title = paste("COVID-19 in Texas"),
                 x = NULL,
                 y = NULL) +
            scale_y_continuous(label = comma) +
            scale_x_date(date_labels = "%b-%y",
                         date_breaks = "month") +
            dd_theme + 
            theme(legend.position = "none")
            
        ggplotly(p, tooltip = "text") %>%
            layout(hovermode = "x unified")
        
    })
    
})

