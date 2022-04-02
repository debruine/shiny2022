### plot_tab -----
plot_tab <- tabItem(
  tabName = "plot_tab",
  selectInput("trait", NULL,
              choices = names(breed_traits)[-c(1, 8, 9)]
  ),
  plotOutput("dog_plot")
)
