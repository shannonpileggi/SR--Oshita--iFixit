library(shiny)

shinyUI(fluidPage(
  
  # App title
  titlePanel("Predict Survival Probabilities"),
  
  # Sidebar layout with input and output definitions
  sidebarLayout(
    
    # Sidebar panel for inputs
    sidebarPanel(
      
      # Input: Select a file
      fileInput("file1", "Choose CSV File",
                multiple = TRUE,
                accept = c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv")),

      checkboxInput("summary", "Display Summary", FALSE),
      
      tags$hr(), # -------------
      
      # Input: times at which to predict survival probabilities
      textInput("times", "Time(s) to Predict:", value = "", placeholder = "ex: 0.5, 1, 10"),
      
      actionButton("predict", "Predict"),
      
      tags$hr(),# -------------
      
      # Summary output
      tableOutput("sum_stats")
      
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      tabsetPanel(
        tabPanel("Calculate Survival Probability", verbatimTextOutput("surv_probs")),
        tabPanel("Input Data", tableOutput("contents"))
      )
      
    )
    
  )
))
