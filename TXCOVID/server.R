# libraries ----
library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(forcats)
library(scales)
library(readr)
library(leaflet)

# import ----

# load theme elements
devtools::source_url(
    "https://raw.githubusercontent.com/markjrieke/thedatadiary/main/dd_theme_elements/dd_theme_elements.R"
    )

# load NYT data - will always be live
f_counties <- read_csv("data/county_data.csv")
f_counties <- f_counties %>%
    mutate(date = as.Date(date))

# server ----
shinyServer(function(input, output) {
    
    # output state map title
    output$text_state_map <- renderText({
        paste(
            if (input$input_type == "avg") {
                "14-Day Average of "
            } else {
                "Total "
            },
            
            if (input$input_count == "cases") {
                "Cases "
            } else {
                "Deaths "
            },
            
            if (input$input_scale == "norm") {
                "per 100,000"
            } else {
                ""
            },
            
            sep = ""
        )
    })
    
    # output leaflet map
    output$map_leaflet <- renderLeaflet({
        
        # create plot specific frame
        if (input$input_type == "avg") {
            if (input$input_count == "cases") {
                if (input$input_scale == "norm") {
                    
                    f_map_plot <- f_counties %>%
                        filter(date == max(date),
                               !county %in% c("Unknown", "State of Texas")) %>%
                        select(county, avg_cases_norm, avg_lat, avg_long)
                        
                } else { # input_scale == "abs"
                    
                    f_map_plot <- f_counties %>%
                        filter(date == max(date),
                               !county %in% c("Unknown", "State of Texas")) %>%
                        select(county, avg_cases, avg_lat, avg_long)
                    
                }
            } else { # input_count == "deaths"
                if (input$input_scale == "norm") {
                    
                    f_map_plot <- f_counties %>%
                        filter(date == max(date),
                               !county %in% c("Unknown", "State of Texas")) %>%
                        select(county, avg_deaths_norm, avg_lat, avg_long)
                    
                } else { # input_scale == "abs"
                    
                    f_map_plot <- f_counties %>%
                        filter(date == max(date),
                               !county %in% c("Unknown", "State of Texas")) %>%
                        select(county, avg_deaths, avg_lat, avg_long)
                    
                }
            }
        } else { # input_type == "cum"
            if (input$input_count == "cases") {
                if (input$input_scale == "norm") {
                    
                    f_map_plot <- f_counties %>%
                        filter(date == max(date),
                               !county %in% c("Unknown", "State of Texas")) %>%
                        select(county, cases_norm, avg_lat, avg_long)
                    
                } else { # input_scale == "abs"
                    
                    f_map_plot <- f_counties %>%
                        filter(date == max(date),
                               !county %in% c("Unknown", "State of Texas")) %>%
                        select(county, cases, avg_lat, avg_long)
                    
                }
            } else { # input_count == "deaths"
                if(input$input_scale == "norm") {
                    
                    f_map_plot <- f_counties %>%
                        filter(date == max(date),
                               !county %in% c("Unknown", "State of Texas")) %>%
                        select(county, deaths_norm, avg_lat, avg_long)
                    
                } else { # input_scale == "abs"
                    
                    f_map_plot <- f_counties %>%
                        filter(date == max(date),
                               !county %in% c("Unknown", "State of Texas")) %>%
                        select(county, deaths, avg_lat, avg_long)
                    
                }
            }
        }
        
        colnames(f_map_plot) <- c("county", "var", "avg_lat", "avg_long")
        
        # set color of bubble
        if (input$input_count == "cases") {
            bubble_color <- dd_blue
        } else {
            bubble_color <- dd_red
        }
        
        # set var_tooltip
        if (input$input_type == "avg") {
            var_tooltip_a <- "14-Day Avg. of "
        } else { # input_type == "cum"
            var_tooltip_a <- "Total "
        }
        
        if (input$input_count == "cases") {
            var_tooltip_b <- "Cases "
        } else { # input_type == "deaths"
            var_tooltip_b <- "Deaths "
        }
        
        if (input$input_scale == "norm") {
            var_tooltip_c <- "per 100,000"
        } else { # input_scale == "abs"
            var_tooltip_c <- NULL
        }
        
        var_tooltip <- paste(
            var_tooltip_a,
            var_tooltip_b,
            var_tooltip_c,
            sep = ""
        )
        
        # set tooltip text
        map_tooltip <- paste(
            "<b>County:</b> ", f_map_plot$county, "<br/>",
            "<b>", var_tooltip, ": </b>", comma(f_map_plot$var, accuracy = 1)
        ) %>%
            lapply(htmltools::HTML)
        
        f_map_plot %>%
            leaflet() %>%
            addTiles() %>%
            addProviderTiles(providers$CartoDB.Positron) %>%
            addCircleMarkers(
                ~avg_long,
                ~avg_lat,
                fillColor = bubble_color,
                fillOpacity = 0.5,
                stroke = FALSE,
                radius = ~var/max(var) * input$input_bubble,
                label = map_tooltip,
                labelOptions = labelOptions(style = list("font-weight" = "normal",
                                                         padding = "3px 8px"),
                                            textsize = "13px",
                                            direction = "auto")
            )
        
    })
    
    # output state line title
    output$text_state_line <- renderText({
        paste(
            if (input$input_type == "avg") {
                "14-Day Average of "
            } else {
                "Total "
            },
            
            if (input$input_count == "cases") {
                "Cases "
            } else {
                "Deaths "
            },
            
            if (input$input_scale == "norm") {
                "per 100,000"
            } else {
                ""
            },
            
            sep = ""
        )
    })
    
    # output state line plot
    output$state_lineplot <- renderPlotly({
        
        # create plot specific frame
        if (input$input_type == "avg") {
            if (input$input_count == "cases") {
                if (input$input_scale == "norm") {
                    
                    f_state_line <- f_counties %>%
                        filter(county == "State of Texas") %>%
                        select(date, county, avg_cases_norm)
                    
                } else { # input_scale == "abs"
                    
                    f_state_line <- f_counties %>%
                        filter(county == "State of Texas") %>%
                        select(date, county, avg_cases)
                    
                }
            } else { # input_count == "deaths"
                if (input$input_scale == "norm") {
                    
                    f_state_line <- f_counties %>%
                        filter(county == "State of Texas") %>%
                        select(date, county, avg_deaths_norm)
                    
                } else { # input_scale == "abs"
                    
                    f_state_line <- f_counties %>%
                        filter(county == "State of Texas") %>%
                        select(date, county, avg_deaths)
                    
                }
            }
        } else { # input_type == "cum"
            if (input$input_count == "cases") {
                if (input$input_scale == "norm") {
                    
                    f_state_line <- f_counties %>%
                        filter(county == "State of Texas") %>%
                        select(date, county, cases_norm)
                    
                } else { # input_scale == "abs"
                    
                    f_state_line <- f_counties %>%
                        filter(county == "State of Texas") %>%
                        select(date, county, cases)
                    
                }
            } else { # input_count == "deaths"
                if(input$input_scale == "norm") {
                    
                    f_state_line <- f_counties %>%
                        filter(county == "State of Texas") %>%
                        select(date, county, deaths_norm)
                    
                } else { # input_scale == "abs"
                    
                    f_state_line <- f_counties %>%
                        filter(county == "State of Texas") %>%
                        select(date, county, deaths)
                    
                }
            }
        }
        
        # set colnames
        colnames(f_state_line) <- c("date", "county", "var")
        
        # set color
        if (input$input_count == "cases") {
            color_line = dd_blue
        } else { # input_count == "deaths"
            color_line = dd_red
        }
        
        # set tooltip and title
        if (input$input_type == "avg") {
            tooltip_state_line_a <- "14-Day avg of "
            title_state_line_a <- "14-Day avg of "
        } else { # input_type == "cum"
            tooltip_state_line_a <- "Total "
            title_state_line_a <- "Total "
        }
        
        if (input$input_count == "cases") {
            tooltip_state_line_b <- "Cases "
            title_state_line_b <- "Cases "
        } else { # input_count == "deaths"
            tooltip_state_line_b <- "Deaths "
            title_state_line_b <- "Deaths "
        }
        
        if (input$input_scale == "norm") {
            tooltip_state_line_c <- "per 100,000: "
            title_state_line_c <- "per 100,000"
        } else { # input_scale == "abs"
            tooltip_state_line_c <- ": "
            title_state_line_c <- ""
        }
        
        tooltip_state_line <- paste(
            tooltip_state_line_a,
            tooltip_state_line_b,
            tooltip_state_line_c,
            sep = ""
        )
        
        title_state_line <- paste(
            title_state_line_a,
            title_state_line_b,
            title_state_line_c,
            sep = ""
        )
        
        # create baseline ggplot
        p_state_line <- f_state_line %>%
            ggplot(aes(x = date,
                       y = var,
                       text = paste("<b>",
                                    tooltip_state_line,
                                    "</b><br>",
                                    number(var,
                                           big.mark = ",",
                                           accuracy = 1)))) +
            geom_path(group = 1,
                      color = color_line) +
            dd_theme +
            labs(x = NULL,
                 y = NULL) +
            scale_x_date(date_breaks = "month",
                         date_labels = "%b") +
            scale_y_continuous(label = comma)
        
        ggplotly(p_state_line, tooltip = "text") %>%
            layout(hovermode = "x unified")
        
    })
    
    # output county comparison plot title
    {
        # rendertext issue?
    }
    
    # output county comparison line plot
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

