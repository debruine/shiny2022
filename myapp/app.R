# libraries ----
suppressPackageStartupMessages({
    library(shiny)
    library(shinyjs)
    library(shinydashboard)
})

# setup ----


# functions ----
source("scripts/func.R") # helper functions

# user interface ----

## tabs ----

### layout_tab ----
layout_tab <- tabItem(
  tabName = "layout_tab",
  fluidRow(
    box("A", title = "2x100", width = 2, height = 100),
    box("B", title = "1x100", width = 1, height = 100),
    box("C", title = "2x200", width = 2, height = 200),
    box("D", title = "3x300", width = 3, height = 300),
    box("E", title = "4x100", width = 4, height = 100),
    box("F", title = "5x100", width = 5, height = 100),
    box("G", title = "7x100", width = 7, height = 100)
  ),
  column(width = 6,
         box("A", title = "12x100", width = 12, height = 100),
         box("B", title = "6x100", width = 6, height = 100),
         box("C", title = "6x200", width = 6, height = 200)
  ),
  column(width = 4,
         box("D", title = "12x300", width = 12, height = 300),
         box("E", title = "12x100", width = 12, height = 100)
  ),
  column(width = 2,
         box("F", title = "12x100", width = 12, height = 100),
         box("G", title = "12x100", width = 12, height = 100)
  )
)

### demo_tab ----
demo_tab <- tabItem(tabName = "demo_tab",
                    box(
                      title = "Personal Info",
                      collapsible = TRUE,
                      solidHeader = TRUE,
                      width = 8,
                      textInput("given", "Given Name"),
                      textInput("surname", "Surname"),
                      selectInput(
                        "pet",
                        "What is your favourite pet?",
                        choices = c("", "cats", "dogs", "ferrets")
                      )
                    ),
                    box(
                      title = "Biography",
                      width = 4,
                      textAreaInput("bio", NULL,
                                    height = "100px",
                                    placeholder = "Brief bio")
                    ))


### demo_tab2 ----
demo_tab2 <- tabItem(tabName = "demo_tab2",
                     h2("Info and value boxes"),
                     infoBox(title = "Date",
                             subtitle = "Today",
                             value = lubridate::today(),
                             icon = icon("calendar"),
                             width = 6),
                     valueBox(value = lubridate::today(),
                              subtitle = NULL,
                              color = "fuchsia",
                              width = 6),
                     tabBox(
                       title = "Test Yourself",
                       width = 12,
                       tabPanel(title = "Question",
                                "What function creates tabBox contents?"),
                       tabPanel(title = "Answer",
                                "tabPanel()")
                     )
)

skin_color <- "purple"
random_icon <- "canadian-maple-leaf"
## UI ----
ui <- dashboardPage(
    skin = skin_color,
    dashboardHeader(title = "Basic Template",
        titleWidth = "calc(100% - 44px)" # puts sidebar toggle on right
    ),
    dashboardSidebar(
        # https://fontawesome.com/icons?d=gallery&m=free
        sidebarMenu(
            id = "tabs",
            menuItem("Layout Demo", tabName = "layout_tab", icon = icon("heart")),
            menuItem("Demographics", tabName = "demo_tab", icon = icon(random_icon)),
            menuItem("Info Boxes", tabName = "demo_tab2", icon = icon("dragon"))
        ),
        tags$a(href = "https://debruine.github.io/shinyintro/",
               "ShinyIntro book", style="padding: 1em;")
    ),
    dashboardBody(
        shinyjs::useShinyjs(),
        tags$head(
            # links to files in www/
            tags$link(rel = "stylesheet", type = "text/css", href = "basic_template.css"),
            tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
            tags$script(src = "custom.js")
        ),
        tabItems(demo_tab, demo_tab2, layout_tab)
    )
)


# server ----
server <- function(input, output, session) {
    output$logo <- renderImage({
        list(src = "www/img/shinyintro.png",
             width = "300px",
             height = "300px",
             alt = "ShinyIntro hex logo")
    }, deleteFile = FALSE)
}

shinyApp(ui, server)
