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

shinyServer(
  function(input, output) {
    
    output$contents <- renderTable({
      req(input$file1)
      df <- read.csv(input$file1$datapath,
                     header = input$header)
      
      if(input$disp == "head") {
        return(head(df))
      }
      else {
        return(df)
      }
    })
})


