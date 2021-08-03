#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Goal: to allow for interactive plotting of surface EMG data
#
# Future goal: add rectification function, add de-noise function
# Even more future goal: allow for data table generation and download
#

library(shiny)

options(shiny.maxRequestSize = 30 * 1024 ^ 2)

library(ggplot2)
library(dplyr)
library(tidyr)
library(ggpubr)
source("loadSensorData.R")

df <-
  read.table(
    text = "",
    col.names = c(
      't',
      'state',
      'Elbow_Torque',
      'Shoulder_Torque',
      "Bicep",
      "TriLat",
      "AntDel",
      "MidDel",
      "PosDel",
      "Pec",
      "LowerTrap",
      "UpperTrap"
    )
  )
sample_data <- loadSensorData('set03_trial05.txt')

# Define UI for application that draws a histogram
ui <- fluidPage(
  fluidRow(column(
  width = 10,
  offset = 1,
  h2('Interactive plotting for data analyses')
)),
 fluidRow(column(
  4,
  radioButtons(
    inputId = 'useSampleData',
    label = NULL,
    choices = c(
      'Use Sample Data' = 1,
      'Use Uploaded Data' = 2
    )
  )
),
column(
  6,
  fileInput(
    inputId = 'selectedFile',
    label = 'Select file to upload',
    accept = '.txt',
    width = '110%'
  )
) # TBD: it would be the best if we allow user input to specify local files
# to read local files based on subject id, task selected, setNr and trialNr
# may only be available downloaded and run locally
# this function may not be applicable if shiny is uploaded to server
),
fluidRow(navbarPage(
  " ",
  #can maybe turn this title into a mini about_me.md hyperlinked
  tabPanel("Torque",
           fluidRow(
             column(6, h4("Elbow Torque"),
                    fluidRow(column(
                      12,
                      plotOutput('elbow_zoom',
                                 height = 300)
                    )),
                    fluidRow(column(
                      12,
                      plotOutput(
                        'elbow',
                        height = 150,
                        brush = brushOpts(
                          id = 'elbow_brush',
                          direction = 'x',
                          resetOnNew =
                            TRUE
                        )
                      )
                    ))),
             column(6, h4("Shoulder Torque"),
                    fluidRow(column(
                      12, plotOutput('shoulder_zoom',
                                     height = 300)
                    )),
                    fluidRow(column(
                      12, plotOutput(
                        'shoulder',
                        height = 150,
                        brush = brushOpts(
                          id = 'shoulder_brush',
                          direction = 'x',
                          resetOnNew = TRUE
                        )
                      )
                    )))
           )),
  tabPanel("sEMG overview",
           column(10, 
           fluidRow(sliderInput(inputId='yaxis_range',
                    label = 'y-axis range',
                    min = 0.1, max = 0.6,
                    value = 0.35, ticks = FALSE
                    )),
           fluidRow(plotOutput(outputId = 'bicep', height = 150,
                               brush = brushOpts(
                                 id = 'emgBrush',
                                 direction = 'x',
                                 resetOnNew = FALSE
                               ))),
           fluidRow(plotOutput(outputId = 'tricep', height = 150,
                               brush = brushOpts(
                                 id = 'emgBrush',
                                 direction = 'x',
                                 resetOnNew = FALSE
                               ))),
           fluidRow(plotOutput(outputId = 'antDel', height = 150,
                               brush = brushOpts(
                                 id = 'emgBrush',
                                 direction = 'x',
                                 resetOnNew = FALSE
                               ))),
           fluidRow(plotOutput(outputId = 'medDel', height = 150,
                               brush = brushOpts(
                                 id = 'emgBrush',
                                 direction = 'x',
                                 resetOnNew = FALSE
                               ))),
           fluidRow(plotOutput(outputId = 'posDel', height = 150,
                               brush = brushOpts(
                                 id = 'emgBrush',
                                 direction = 'x',
                                 resetOnNew = FALSE
                               ))),
           fluidRow(plotOutput(outputId = 'pec', height = 150,
                               brush = brushOpts(
                                 id = 'emgBrush',
                                 direction = 'x',
                                 resetOnNew = FALSE
                               ))),
           fluidRow(plotOutput(outputId = 'midTrap', height = 150,
                               brush = brushOpts(
                                 id = 'emgBrush',
                                 direction = 'x',
                                 resetOnNew = FALSE
                               ))),
           fluidRow(plotOutput(outputId = 'lowTrap', height = 150,
                               brush = brushOpts(
                                 id = 'emgBrush',
                                 direction = 'x',
                                 resetOnNew = FALSE
                               ))),
           ))#,
  #tabPanel("sEMG select")
)))


# Define server logic required to draw a histogram
server <- function(input, output) {
  data_select <- reactive({
    if (input$useSampleData == 1) {
      return(sample_data)
    }
    else if (input$useSampleData == 2) {
      req(input$selectedFile)
      
      file <- input$selectedFile
      
      if (!is.null(file)) {
        return(loadSensorData(file$datapath))
      } else{
        return(df)
      }
    }
    #sample_data <- loadSensorData('set03_trial05.txt')
  })
  
  #### first tab
  range_elbow <- reactiveValues(x = NULL)
  range_shoulder <- reactiveValues(x = NULL)
  
  output$elbow_zoom <- renderPlot({
    ggplot(data = data_select(), aes(x = t, y = Elbow_Torque, color = state)) +
      geom_line(size = 0.5) + theme(legend.position = "none") +
      coord_cartesian(xlim = range_elbow$x)
  })
  output$shoulder_zoom <- renderPlot({
    ggplot(data = data_select(), aes(x = t, y = Shoulder_Torque, color = state)) +
      geom_line(size = 0.5) + theme(legend.position = "none") +
      coord_cartesian(xlim = range_shoulder$x)
  })
  
  output$elbow <- renderPlot({
    ggplot(data = data_select(), aes(x = t, y = Elbow_Torque, color = state)) +
      geom_line(size = 0.5) + theme(legend.position = "none")
  })
  output$shoulder <- renderPlot({
    ggplot(data = data_select(), aes(x = t, y = Shoulder_Torque, color = state)) +
      geom_line(size = 0.5) + theme(legend.position = "none")
  })
  
  observe({
    brush_elbow <- input$elbow_brush
    if (!is.null(brush_elbow)) {
      range_elbow$x <- c(brush_elbow$xmin, brush_elbow$xmax)
    } else{
      range_elbow$x <- NULL
    }
    brush_shoulder <- input$shoulder_brush
    if (!is.null(brush_shoulder)) {
      range_shoulder$x <- c(brush_shoulder$xmin, brush_shoulder$xmax)
    } else{
      range_shoulder$x <- NULL
    }
    
  })
  
  ######## EMG Summary Tab
  range_emg <- reactiveValues(x = NULL)
  
  yrange <- reactive({
    lim <- c(-input$yaxis_range, input$yaxis_range)
    return (lim)
  })
  
  output$bicep <- renderPlot({
    ggplot(data = data_select(), aes(x = t, y = Bicep, color = state)) +
      geom_line(size = 0.5) + theme(legend.position = "none") +
      coord_cartesian(xlim = range_emg$x, ylim = yrange())
  })
  output$tricep <- renderPlot({
    ggplot(data = data_select(), aes(x = t, y = TriLat, color = state)) +
      geom_line(size = 0.5) + theme(legend.position = "none") +
      coord_cartesian(xlim = range_emg$x, ylim = yrange())
  })
  output$antDel <- renderPlot({
    ggplot(data = data_select(), aes(x = t, y = AntDel, color = state)) +
      geom_line(size = 0.5) + theme(legend.position = "none") +
      coord_cartesian(xlim = range_emg$x, ylim = yrange())
  })
  output$medDel <- renderPlot({
    ggplot(data = data_select(), aes(x = t, y = MidDel, color = state)) +
      geom_line(size = 0.5) + theme(legend.position = "none") +
      coord_cartesian(xlim = range_emg$x, ylim = yrange())
  })
  output$posDel <- renderPlot({
    ggplot(data = data_select(), aes(x = t, y = PosDel, color = state)) +
      geom_line(size = 0.5) + theme(legend.position = "none") +
      coord_cartesian(xlim = range_emg$x, ylim = yrange())
  })
  output$pec <- renderPlot({
    ggplot(data = data_select(), aes(x = t, y = Pec, color = state)) +
      geom_line(size = 0.5) + theme(legend.position = "none") +
      coord_cartesian(xlim = range_emg$x, ylim = yrange())
  })
  output$midTrap <- renderPlot({
    ggplot(data = data_select(), aes(x = t, y = MidTrap, color = state)) +
      geom_line(size = 0.5) + theme(legend.position = "none") +
      coord_cartesian(xlim = range_emg$x, ylim = yrange())
  })
  output$lowTrap <- renderPlot({
    ggplot(data = data_select(), aes(x = t, y = LowTrap, color = state)) +
      geom_line(size = 0.5) + theme(legend.position = "none") +
      coord_cartesian(xlim = range_emg$x, ylim = yrange())
  })
  
  observe({
    brush_emg <- input$emgBrush
    if (!is.null(brush_emg)) {
      range_emg$x <- c(brush_emg$xmin, brush_emg$xmax)
    } else{
      range_emg$x <- NULL
    }
    })
  
  
  
  #########
}

# Run the application
shinyApp(ui = ui, server = server)
