# display debugging messages in R (if local)
# and in the console log (if running in shiny)
debug_msg <- function(...) {
  is_local <- Sys.getenv('SHINY_PORT') == ""
  in_shiny <- !is.null(shiny::getDefaultReactiveDomain())
  txt <- toString(list(...))
  if (is_local) message(txt)
  if (in_shiny) shinyjs::runjs(sprintf("console.debug(\"%s\")", txt))
}

debug_sprintf <- function(fmt, ...) {
  debug_msg(sprintf(fmt, ...))
}

make_dog_plot <- function(data, trait) {
  ggplot(data, aes(x = .data[[trait]])) +
    geom_histogram(
      binwidth = 1,
      fill = "purple"
    ) +
    scale_x_continuous(name=NULL, breaks = 0:5) +
    ggtitle(trait)
}

make_full_plot <- function(data) {
  data %>%
    tidyr::pivot_longer(cols = any_of(names(breed_traits)[-c(1, 8, 9)]),
                        names_to = "trait") %>%
    ggplot(aes(x = value)) +
    geom_histogram(
      binwidth = 1,
      color = "white",
      fill = "purple"
    ) +
    facet_wrap(~trait) +
    scale_x_continuous(name=NULL, breaks = 1:5)
}

