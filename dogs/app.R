# libraries ----
suppressPackageStartupMessages({
    library(shiny)
    library(shinyjs)
    library(shinydashboard)
    library(ggplot2)
    library(dplyr)
    library(DT)
    library(shinyWidgets)
})

# setup ----

theme_set(theme_bw(base_size = 15))

breed_traits <- readr::read_csv('data/breed_traits.csv',
                                show_col_types = FALSE) %>%
    slice(-167)


# functions ----
source("scripts/func.R", local = TRUE) # helper functions

# user interface ----

## tabs ----
### table_tab -----
table_tab <- tabItem(
    tabName = "table_tab",
    h2("Dog Table", id = "dog_id", class = "dog_class"),
    DTOutput("full_data_table"),
    plotOutput("full_plot")
)


source("scripts/plot_tab.R", local = TRUE)

## UI ----
ui <- dashboardPage(
    skin = "purple",
    dashboardHeader(title = "Dogs",
        titleWidth = "calc(100% - 44px)" # puts sidebar toggle on right
    ),
    dashboardSidebar(
        # https://fontawesome.com/icons?d=gallery&m=free
        ### sidebarMenu ----
        sidebarMenu(
            id = "tabs",
            menuItem("Data Table", tabName = "table_tab", icon = icon("dog")),
            menuItem("Distributions", tabName = "plot_tab", icon = icon("chart-line"))
        ),
        actionButton("hide_table", "Hide Table"),
        pickerInput("coat_length_filter",
                    label = "View only breed with these coat types:",
                    choices = unique(breed_traits$`Coat Length`),
                    selected = unique(breed_traits$`Coat Length`),
                    multiple = TRUE),
        checkboxGroupInput("table_col_display",
                   label = "View these columns:",
                   choices = names(breed_traits)[-1],
                   selected = names(breed_traits)[2:3])

    ),
    dashboardBody(
        shinyjs::useShinyjs(),
        tags$head(
            # links to files in www/
            tags$link(rel = "stylesheet", type = "text/css", href = "basic_template.css"),
            tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
            tags$script(src = "custom.js")
        ),
        ### tabItems ----
        tabItems(
            table_tab, plot_tab
        )
    )
)


# server ----
server <- function(input, output, session) {
    # breed_traits_subset ----
    breed_traits_subset <- reactive({
        debug_msg("breed_traits_subset")

        bt <- breed_traits %>%
            filter(`Coat Length` %in% input$coat_length_filter)
        bt[, c("Breed", input$table_col_display)]
    })


    # hide_table ----
    observeEvent(input$hide_table, {
        debug_msg("hide_table")
        toggle("full_data_table")

        if (input$hide_table %% 2 == 0) {
            new_label <- "Hide Table"
        } else {
            new_label <- "Show Table"
        }

        updateActionButton(session, "hide_table", label = new_label)
    })


    # full_data_table ----
    output$full_data_table <- renderDT({
        debug_msg("full_data_table")
        breed_traits_subset()
    })

    # dog_plot ----
    output$dog_plot <- renderPlot({
        debug_msg("dog_plot, trait == ", input$trait)
        make_dog_plot(breed_traits,
                      input$trait)
    })

    # full_plot ----
    output$full_plot <- renderPlot({
        debug_msg("full_plot")
        make_full_plot(data = breed_traits_subset())
    })
}

shinyApp(ui, server)
