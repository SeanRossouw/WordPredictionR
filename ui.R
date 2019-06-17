library(shiny)
library(shinythemes)

shinyUI(fluidPage(
  
  theme=shinytheme("darkly"),
  # Application title
  titlePanel("Word Prediction in R/Shiny"),
  h3("Sean 2019"),
  

  sidebarLayout(
    sidebarPanel(
      textInput("text", label=('Enter text here'), value=''),
      sliderInput("slide",label=("Number of predictions to return"),min=1,max=25,step=1,value=5),
      actionButton("submit", "Submit")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      
      
      wellPanel(
        #Link to repo
        dataTableOutput('table'),
        textOutput('list'),
        helpText(a('For more info',href='http://rpubs.com',target='blank'))
      )
    )
  )
)
)