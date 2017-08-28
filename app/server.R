library(shiny)
library(survival)
library(rms)
x <- read.csv("data/final_data.csv", head = TRUE)
model <-   model <- cph(Surv(time_until_answer, answered) ~ new_category + new_user + 
                               contain_unanswered + contain_answered + title_questionmark + 
                               title_beginwh + text_contain_punct + text_all_lower + update + 
                               greeting + gratitude + prior_effort + weekday + strat(ampm) + 
                               sqrt(avg_tag_score) + poly(text_length, 2) + rcs(device_length, 5) + 
                               rcs(avg_tag_length, 4) + rcs(newline_ratio, 4), 
                             data = x, x = TRUE, 
                             y = TRUE, surv = TRUE)
#------------------------------------------------------------------------------------------------
shinyServer(
  function(input, output) {
    
    #-------Renders head of input data ---------------------------------------
    output$contents <- renderTable({
      
      req(input$file1)
      df <- read.csv(input$file1$datapath)
      data <- oshitar::variable_setup(df)
      return(head(data))
      }
      )
    
    #-------Renders summary statistics of input data-------------------------- 
    output$sum_stats <- renderTable({
      
      if(input$summary == TRUE) {
        req(input$file1)
        df <- read.csv(input$file1$datapath)
        data <- oshitar::variable_setup(df)
        
        summarydf <- data.frame(num = nrow(data), 
                            median_time = round(median(data$time_until_answer),2), 
                            mean = round(mean(data$time_until_answer),2))
        return(summarydf)
      }
    }
    )
    
    #-------Renders predicted survival probabilities-------------------------- 
    timesInput <- eventReactive(input$predict, {
      as.numeric(stringr::str_split(input$times, pattern = ",", simplify = TRUE))
    }
    )

    output$surv_probs <- renderPrint({
      req(input$file1)
      df <- read.csv(input$file1$datapath)
      data <- oshitar::variable_setup(df)
      
      predictions <- pec::predictSurvProb(model, newdata = data_touse, times = timesInput())
      return(predictions)
      }
      )
})


      





