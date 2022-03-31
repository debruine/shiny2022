# Setup ----
library(shiny)

# Define UI ----
ui <- fluidPage(
    titlePanel("Basic Demo"),

    sidebarLayout(
        sidebarPanel = sidebarPanel(
            h2("My favourite things"),
            checkboxGroupInput(
                inputId = "fav_things",
                label = "What are your favourite things?",
                choices = c("Coding", "Cycling", "Cooking")
            ),
            actionButton(inputId = "count_fav_things",
                         label = "Count",
                         icon = icon("calculator"))
        ),
        mainPanel = mainPanel(
            textOutput(outputId = "n_fav_things")
        )
    )
)

# Define server logic ----
server <- function(input, output, session) {
    # observeEvent(input$count_fav_things, {
    #     n <- length(input$fav_things)
    #     count_text <- sprintf("You have %d favourite things.", n)
    #     output$n_fav_things <- renderText(count_text)
    # })

    # count_text <- reactive({
    #     input$count_fav_things # just here to trigger the reactive
    #
    #     n <- length(isolate(input$fav_things))
    #
    #     sprintf("You have %d favourite things.", n)
    # })

    count_text <- eventReactive(input$count_fav_things, {
        n <- length(input$fav_things)

        sprintf("You have %d favourite things.", n)
    })


    output$n_fav_things <- renderText(count_text())
}

# Run the application ----
shinyApp(ui = ui, server = server)
