# libraries ----
library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(forcats)
library(scales)

# setup ----

# load theme elements
devtools::source_url(
    "https://raw.githubusercontent.com/markjrieke/thedatadiary/main/dd_theme_elements/dd_theme_elements.R"
    )

# load from data source
f_counties <- as_tibble(read.csv("data/county_data.csv"))
f_counties <- f_counties %>%
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
        
        # creating subtitle string
        if (input$count_type == "avg") {
            str_suba <- "14-day average of "
        } else {
            str_suba <- "Total "
        }
        
        str_subb <- paste(input$count_var, " ", sep = "")
        
        if (input$count_scale == "norm") {
            str_subc <- "per 100,000 "
        } else {
            str_subc <- NULL
        }
        
        if (input$county1 == "State of Texas") {
            str_county1 <- "the State of Texas"
        } else {
            str_county1 <- paste(input$county1, "County", sep = " ")
        }
        
        if (input$county2 == "State of Texas") {
            str_county2 <- "the State of Texas"
        } else {
            str_county2 <- paste(input$county2, "County", sep = " ")
        }
        
        if (input$county3 == "State of Texas") {
            str_county3 <- "the State of Texas"
        } else {
            str_county3 <- paste(input$county3, "County", sep = " ")
        }
        
        str_subtitle <- paste("Comparing the ", 
                              str_suba, 
                              str_subb, 
                              str_subc, 
                              "in ",
                              str_county1,
                              ", ",
                              str_county2,
                              ", and ",
                              str_county3,
                              ".",
                              sep = "")

        # create ggplot
        p<- f_plot %>%
            filter(county %in% c(input$county1,
                                 input$county2,
                                 input$county3)) %>%
            mutate(county = fct_relevel(county,
                                        input$county1,
                                        input$county2,
                                        input$county3)) %>%
            ggplot(aes(x = date,
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
            labs(title = "COVID-19 in Texas",
                 x = NULL,
                 y = NULL) +
            scale_y_continuous(label = comma) +
            scale_x_date(date_labels = "%b",
                         date_breaks = "month") +
            dd_theme + 
            theme(legend.position = "none")
            
        ggplotly(p, tooltip = "text") %>%
            layout(hovermode = "x unified",
                   title = list(xanchor = "left",
                                x = 0,
                                text = paste("<span style = 'font-size:20px'><b>COVID-19 in Texas</b></span><br>",
                                             "<sup>",
                                             str_suba,
                                             str_subb,
                                             str_subc,
                                             "in ",
                                             "<span style='color:#5565D7;'><b>",
                                             str_county1,
                                             "</b></span>",
                                             ", ",
                                             "<span style='color:#D75565;'><b>",
                                             str_county2,
                                             "</b></span>",
                                             ", and ",
                                             "<span style='color:#65d755;'><b>",
                                             str_county3,
                                             "</b></span>",
                                             ".",
                                             "</sup>",
                                             sep = "")))
        
    })
    
})

