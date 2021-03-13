# libraries ----
library(shiny)

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
                         list("Weekly average" = "avg",
                              "Cumulative" = "cum"))
        ),
        mainPanel(
            plotOutput("lineplot")
        )
    )
)
