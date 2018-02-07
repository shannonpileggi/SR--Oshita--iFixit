library(shiny)

shinyUI(fluidPage(
  
  # App title
  titlePanel("Predict Failure Probabilities"),
  helpText("Failure is defined as the event that a question receives an answer. This app predicts the 
           probability that a question posted on iFixit's Answers forum fails, or receives an answer 
           before a certain time. The time (in hours) is specified by the user."),
    
  tabsetPanel(
      
      tabPanel("Input Data Summary",
               br(),
               sidebarLayout(
                 sidebarPanel(
                   helpText("Upload the CSV file. This app will set up
                            the variables required"),
                   fileInput("file1", "Upload CSV File",
                             multiple = TRUE,
                             accept = c(".csv")),
                   tags$hr(),
                   checkboxInput("km", "Display Kaplan-Meier Estimated Failure Probabilities", FALSE),
                   tags$hr(),
                   p("Kaplan-Meier Estimated failure probabilities adjust to the presence of censoring, or in this 
                            case, the presence of unanswered questions."),
                   p(strong("Example Interpretation:")),
                   p("KM Estimated Failure probability at 3 hours: 0.10"),
                   p("The probability that a question recieves an answer before 3 hours have passed since it was posted
                     is 0.10. ")
                 ),
                 mainPanel(
                   br(),
                   tableOutput("sum_stats"), 
                   br(),
                   tableOutput("contents"),
                   br(),
                   tableOutput("estimates")
                 )
                 )
               ),
      tabPanel("Calculate Predicted Failure", 
               br(),
               sidebarLayout(
                 sidebarPanel(
                   textInput("times", "Time(s) to Predict:", value = "", placeholder = "ex: 1, 5, 10"),
                   actionButton("predict", "Predict"),
                   br(),
                   tags$hr(),
                   p(strong("Example interpretation:")),
                   p("Failure probabilility at 3 hours: 0.10"),
                   p("The probability that a question recieves an answer before 3 hours have passed since it was
                     posted is 0.10")
                 ),
                 mainPanel(
                   helpText("Failure probabilities are calculated using the predictSurvProb function from the pec package"),
                   tableOutput("surv_probs"))
               )),
      tabPanel("Cox Regression Model Summary", 
               br(),
               helpText("Overview of the model used to obtain predicted failure probabilities"),
               br(), 
               mainPanel(
                 fluidRow(
                   column(width = 4, tableOutput("modelvars")),
                   column(width = 4, tableOutput("modelstats")),
                   column(width = 3, tableOutput("modelcoeff"))
                 )
               )
      )
)
)
)


