# libraries ----
suppressPackageStartupMessages({
    library(shiny)
    library(shinyjs)
    library(shinydashboard)
    library(ggplot2)
    library(DT)
    library(dplyr)
    library(googlesheets4)
})

# setup ----

gs4_auth(email = "debruine@gmail.com")
sheet_id <- "https://docs.google.com/spreadsheets/d/1tQCYQrI4xITlPyxb9dQ-JpMDYeADovIeiZZRNHkctGA/"
demo_data <- read_sheet(sheet_id)

budget_data <- readr::read_csv("data/budget.csv",
                               show_col_types = FALSE)


# functions ----
source("scripts/func.R") # helper functions

# user interface ----

## tabs ----

### data_tab ----
data_tab <- tabItem(
  tabName = "data_tab",
  DTOutput("data_table_example")
)

### reactive_tab ----
reactive_tab <- tabItem(
    tabName = "reactive_tab",
    box(
        title = "Diamonds",
        solidHeader = TRUE,
        selectInput("cut", "Cut", levels(diamonds$cut)),
        selectInput("color", "Color", levels(diamonds$color)),
        selectInput("clarity", "Clarity", levels(diamonds$clarity)),
        actionButton("update", "Update"),
        actionButton("do_something", "Do Something")
    ),
    box(
        title = "Plot",
        solidHeader = TRUE,
        textOutput("title"),
        plotOutput("plot")
    ),
    box(width = 12,
        title = "Table",
        solidHeader = TRUE,
        DTOutput("diamond_table")
    )
)

### outputs_tab ----
outputs_tab <- tabItem(
    tabName = "outputs_tab",
    tabBox(width = 12,
        tabPanel("textOutput",
                 h2("Text"),
                 textOutput("demo_text"),
                 h2("verbatim text"),
                 verbatimTextOutput("demo_verbatim")
                 ),
        tabPanel("plotOutput",
                 plotOutput("demo_plot",
                            width = "100%",
                            height = "400px")),
        tabPanel("imageOutput",
                 imageOutput("demo_image",
                             width = "200px",
                             height = "200px")),
        tabPanel("tableOutput",
                 tableOutput("demo_table")),
        tabPanel("DTOutput",
                 DTOutput("demo_dt")),
        tabPanel("uiOutput",
                 uiOutput("demo_ui"))
    )
)

### inputs_tab ----
inputs_tab <- tabItem(
    tabName = "inputs_tab",
    box(title= "Demographics", width = 6, solidHeader = TRUE,
        textInput("demo_text",
                  label = "Name",
                  value = ""),
        textAreaInput("demo_textarea",
                      label = "Biography",
                      rows = 5,
                      placeholder = "Tell us something about you."),
        dateInput("demo_date",
                  label = "What is your birthdate?",
                  value = NULL,
                  min = "1900-01-01",
                  max = Sys.Date(),
                  format = "yyyy-mm-dd",
                  startview = "year")
    ),
    box(title = "Questions", width = 6, solidHeader = TRUE,
        selectInput("demo_select",
                    label = "Do you like Shiny?",
                    choices = c("", "Yes", "No"),
                    selected = NULL),
        selectInput("demo_selectize",
                    label = "Gender (select all that apply)",
                    choices = list( # no blank needed
                        "Non-binary" = "nb",
                        "Male" = "m",
                        "Female" = "f",
                        "Agender" = "a",
                        "Gender Fluid" = "gf"
                    ),
                    multiple = TRUE,
                    selectize = TRUE),
        checkboxGroupInput("demo_cbgi",
                           label = "Gender (select all that apply)",
                           choices = list( # no blank needed
                               "Non-binary" = "nb",
                               "Male" = "m",
                               "Female" = "f",
                               "Agender" = "a",
                               "Gender Fluid" = "gf"
                           ),
                           inline = FALSE
                           ),
        radioButtons("demo_radio",
                     label = "Choose one",
                     choices = c("Cats","Dogs"),
                     selected = "",
                     inline = TRUE)

    ),
    box(title = "Answers", width = 12, solidHeader = TRUE,
        verbatimTextOutput("answers")
    )

)



skin_color <- "red"
## UI ----
ui <- dashboardPage(
    skin = skin_color,
    dashboardHeader(title = "Day 2",
        titleWidth = "calc(100% - 44px)" # puts sidebar toggle on right
    ),
    dashboardSidebar(
        # https://fontawesome.com/icons?d=gallery&m=free
        sidebarMenu(
            id = "tabs",
            menuItem("Data", tabName = "data_tab", icon = icon("dog")),
            menuItem("Reactive", tabName = "reactive_tab", icon = icon("bell")),


            menuItem("Outputs", tabName = "outputs_tab", icon = icon("cog")),
            menuItem("Inputs", tabName = "inputs_tab", icon = icon("dragon"))
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
            inputs_tab, outputs_tab, reactive_tab, data_tab
        )
    )
)


# server ----
server <- function(input, output, session) {
  # outputs ----

  ## data_table_example ----
  output$data_table_example <- renderDT({
    debug_msg("output$data_table_example")
    demo_data
  })

  ## answers ----
  output$answers <- renderText({
      input$demo_selectize
  })

  ## demo_text ----
  output$demo_text <- renderText({
      paste(LETTERS, collapse = ", \n")
  })

  ## demo_verbatim ----
  output$demo_verbatim <- renderText({
      paste(LETTERS, collapse = ", \n")
  })

  ## demo_plot ----
  output$demo_plot <- renderPlot({
      ggplot(iris, aes(x = Species, y = Sepal.Width)) +
          geom_violin()
  }, height = function(){200})

  ## demo_image ----
  output$demo_image <- renderImage({
      list(src = "www/img/shinyintro.png",
           width = 200, height = 200,
           alt = "Hex logo for shinyintro")
  }, deleteFile=FALSE)

  ## demo_table ----
  output$demo_table <- renderTable({
      iris
  })

  ## demo_dt ----
  output$demo_dt <- renderDT({
      iris %>%
          select(Species, SL = Sepal.Length)
  }, options = list(
      pageLength = 5, # how many rows are displayed
      lengthChange = FALSE, # whether pageLength can change
      info = TRUE, # text with the total number of rows
      paging = TRUE, # if FALSE, the whole table displays
      ordering = FALSE, # whether you can reorder columns
      searching = FALSE # whether you can search the table
  ))


  ## demo_ui ----
  output$demo_ui <- renderUI({
      colnames <- names(iris)

      tagList(
          HTML("<h2>Iris</h2>"),
          checkboxGroupInput("iris_cols",
                         "Select columns",
                         choices = colnames)
      )
  })


  ## title ----
  output$title <- renderText({
    diamond_title()
  })

  ## plot ----
  output$plot <- renderPlot({
      ggplot(selected_diamonds(),
             aes(x = carat, y = price)) +
          geom_point(color = "tomato", alpha = 0.5) +
          geom_smooth(method = lm, formula = y~x)
  })

  ## diamond_table ----
  output$diamond_table <- renderDataTable({
      selected_diamonds()
  })

  # reactives ----

  ## selected_diamonds ----
  selected_diamonds <- eventReactive(input$update, {
     diamonds %>%
          filter(cut == input$cut,
                 color == input$color,
                 clarity == input$clarity)
  })

  ## diamond_title ----
  diamond_title <- eventReactive(input$update, {
    paste0("Cut: ", input$cut,
           ", Color: ", input$color,
           ", Clarity: ", input$clarity)
  })

  ## do_something ----
  # observeEvent(input$do_something, {
  #   showNotification("Did something.")
  # })

  observeEvent(input$do_something, {
    text <- paste("Did something ",
                  input$do_something,
                  "times, and updated",
                  input$update, "times")
    showNotification(text)
  })

}

shinyApp(ui, server)
