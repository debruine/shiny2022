### table_tab -----
table_tab <- tabItem(
  tabName = "table_tab",
  h2("Dog Table", id = "dog_id", class = "dog_class"),
  actionButton("hide_table", "Hide/Show Table"),
  checkboxGroupInput("table_col_display", label = NULL,
                     choices = names(breed_traits)[-1],
                     selected = ""),
  DTOutput("full_data_table")
)
