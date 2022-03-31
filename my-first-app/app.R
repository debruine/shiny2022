#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("My First App"),

    p("I am explaining this perfectly."),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            radioButtons(inputId = "display_var",
                         label = "Which variable to display",
                         choices = c("Waiting time to next eruption" = "waiting",
                                     "Eruption time" = "eruptions"),
                         selected = "waiting"
                         ),
            sliderInput("bins",
                        "Choose the best best number:",
                        min = 10,
                        max = 40,
                        value = 25)
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("distPlot")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$distPlot <- renderPlot({
        if (input$display_var == "waiting") {
          label <- "Waiting time to next eruption"
        } else {
          label <- "Eruption time"
        }

        ggplot(faithful, aes(x = .data[[input$display_var]])) +
            geom_histogram(bins = input$bins,
                           fill = "#428BCA",
                           color = "white") +
            labels(x = label)
    })
}

# Run the application
shinyApp(ui = ui, server = server)
