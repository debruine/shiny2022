# libraries ----
suppressPackageStartupMessages({
    library(shiny)
    library(shinyjs)
    library(shinydashboard)
    library(ggplot2)
    library(dplyr)
    library(DT)
})

# setup ----

theme_set(theme_bw(base_size = 15))

breed_traits <- readr::read_csv('data/breed_traits.csv')



# functions ----
source("scripts/func.R") # helper functions

# user interface ----

## tabs ----

### table_tab -----
table_tab <- tabItem(
    tabName = "table_tab",
    DTOutput("full_data_table")
)

### plot_tab -----
plot_tab <- tabItem(
    tabName = "plot_tab",
    selectInput("trait", NULL,
                choices = names(breed_traits)[-c(1, 8, 9)]
    ),
    plotOutput("dog_plot")
)

## UI ----
ui <- dashboardPage(
    skin = "purple",
    dashboardHeader(title = "Dogs",
        titleWidth = "calc(100% - 44px)" # puts sidebar toggle on right
    ),
    dashboardSidebar(
        # https://fontawesome.com/icons?d=gallery&m=free
        sidebarMenu(
            id = "tabs",
            menuItem("Data Table", tabName = "table_tab", icon = icon("dog")),
            menuItem("Distributions", tabName = "plot_tab", icon = icon("chart-line"))
        )
    ),
    dashboardBody(
        shinyjs::useShinyjs(),
        tags$head(
            # links to files in www/
            tags$link(rel = "stylesheet", type = "text/css", href = "basic_template.css"),
            tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
            tags$script(src = "custom.js")
        ),
        tabItems(
            table_tab, plot_tab
        )
    )
)


# server ----
server <- function(input, output, session) {
    # full_data_table ----
    output$full_data_table <- renderDT({
        breed_traits
    })

    # dog_plot ----
    output$dog_plot <- renderPlot({
        ggplot(breed_traits, aes(x = .data[[input$trait]])) +
            geom_histogram(
                binwidth = 1,
                color = "white",
               fill = rgb(96,92,168, maxColorValue = 255)
            ) +
            scale_x_continuous(name=NULL, breaks = 0:5) +
            ggtitle(input$trait)

    })
}

shinyApp(ui, server)
