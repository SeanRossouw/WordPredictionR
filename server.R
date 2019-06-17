source('prediction.R')
library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
     
     observeEvent( input$submit,{
     
     inputTxt=input$text
     inputSlide=input$slide
     prediction=f.predict(inputTxt,inputSlide)
     output$table=renderDataTable(data.table(prediction),options = list(searching = FALSE))
   })
  
    #output$table=renderDataTable(prediction)
  })
  
