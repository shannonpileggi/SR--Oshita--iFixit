library(shiny); library(survival); library(rms)

# data to build the cox regression model on 
x <- as.data.frame(read.csv("data/finaldata.csv", head = TRUE)); x <- x[,-1]

model <- cph(Surv(time_until_answer, answered) ~ new_category + new_user + 
                    contain_unanswered + contain_answered + title_questionmark + 
                    text_contain_punct + text_all_lower + update + prior_effort + 
                    day + sqrt(avg_tag_score) + rcs(log10(text_length), 5) + 
                    rcs(log10(avg_tag_length + 1), 4) + rcs(log10(device_length + 1), 5) + 
                    rcs(sqrt(newline_ratio), 3), 
                  data = x, 
                  x = TRUE, y = TRUE, 
                  surv = TRUE)

#-----------------------------------------------------------------------------
shinyServer(
  function(input, output) {
    
    #-------Renders summary statistics of input data-------------------------- 
    output$sum_stats <- renderTable({
      req(input$file1)
      df <- as.data.frame(read.csv(input$file1$datapath)) 
      data <- oshitar::variable_setup(df)
        
      summarydf <- data.frame(nrow(data), 
                              round(median(data$time_until_answer), 2), 
                              round(sum(data$answered)/nrow(data), 2),
                              round(mean(data$time_until_answer), 2),
                              round(max(data$time_until_answer), 2),
                              round(min(data$time_until_answer), 2)
                              )
      colnames(summarydf) <- c("Number of Questions", "Proportion Answered","Median Answer Time (hrs)",
                               "Mean Answer Time", "Longest Answer Time", "Shortest Answer Time"
                               )
      return(summarydf)
    }
    )
    
    #-------Renders head of input data ---------------------------------------
    output$contents <- renderTable({
      
      req(input$file1)
      df <- read.csv(input$file1$datapath)
      data <- oshitar::variable_setup(df)
      return(head(data))
    }
    )
    
    #-------Renders KM Estimates (failure) -----------------------------------
    output$estimates <- renderTable({
      
      req(input$file1)
      df <- read.csv(input$file1$datapath)
      data <- oshitar::variable_setup(df)
      
      if(input$km == TRUE) {
        surv_object <- Surv(data$time_until_answer, data$answered, type = "right")
        KM <- survfit(surv_object ~ 1, conf.type = "log-log")
        KMdf <- data.frame(data$id, 1 - KM$surv)
        colnames(KMdf) <- c("Question ID", "Failure Probability")
        return(KMdf)
      }

    })
    
    #-------Renders predicted survival probabilities-------------------------- 
    timesInput <- eventReactive(input$predict, {
      as.numeric(stringr::str_split(input$times, pattern = ",", simplify = TRUE))
    }
    )

    output$surv_probs <- renderTable({
      req(input$file1)
      df <- read.csv(input$file1$datapath)
      data <- oshitar::variable_setup(df)
      
      predictions <- pec::predictSurvProb(model, newdata = as.data.frame(data), times = timesInput())
      predictdf <- data.frame(data$id, 1 - predictions)
      colnames(predictdf) <- c("Question ID", timesInput())
      return(predictdf)
      }
      )
    
    #-------Renders summary of CR model---------------------------------------
    output$modelvars <- renderTable({
      vars <- data.frame(c("new_category", "new_user", "contain_unanswered", "contain_answered", "title_questionmark",
                   "text_contain_punct", "text_all_lower", "update", "prior_effort", "day", "square root of avg_tag_score", 
                   "spline on log transformed text length", "spline on log transformed device_length", "spline on log transformed avg_tag_length",
                   "spline on square root transformed newline_ratio"))
      colnames(vars) <- "Variables Included"
      return(vars)
    })
    
    output$modelstats <- renderTable({
      stat <- data.frame(names(model$stats), unname(model$stats))
      colnames(stat) <- c("Model Statistics", " ")
      stat <- stat[-c(10:11),]
      return(stat)
    })
    
    output$modelcoeff <- renderTable({
      data.frame(Predictors = names(model$coefficients), Coefficients = unname(model$coefficients))
    })
    

})


      





