library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Survival Probabilities"),
  
  # Sidebar with a slider input for the number of bins
  sidebarLayout(
    
    sidebarPanel(
      fileInput("file1", "Choose CSV file",
                multiple = TRUE,
                accept = c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv")),
      tags$hr(),
      
      checkboxInput("header", "Header", TRUE),
      
      tags$hr()
      ),
    mainPanel(
      tableOutput("contents")
    )
  )
))
