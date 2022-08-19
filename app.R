#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#


library(shiny)
library(reticulate)
library(bslib)
library(ggfittext)
library(plasmapR)

#on the directory: virtualenv env
#source env/bin/activate
#to check: which python
reticulate::virtualenv_create("python35_env", python = "python3")
reticulate::virtualenv_install("python35_env", packages = c("pandas", "numpy", "biopython"))
reticulate::use_virtualenv("python35_env", required = TRUE)

source("FUNS.R")

my_theme <- bs_theme(bootswatch = "flatly",
                     base_font = font_google("Righteous"))
## Only run examples in interactive R sessions
ui <- fluidPage(
  theme = my_theme,
  navbarPage("MiVector!",
             tabPanel("About",
                      p("Description")),
             tabPanel("Option 1",
                      sidebarLayout(
                        sidebarPanel(
                          fileInput("file1",
                                    "Choose GenBank File",
                                    accept = c(".gb", ".gbk")),
                          textInput(inputId = "plasname",
                                    label = "Plasmid Name"),
                          uiOutput("checkbox"),
                          sliderInput(inputId = "rotation",
                                      label = "Rotate Plot",
                                      min = -180,
                                      max = 180,
                                      value = 0,
                                      step = 1),
                          sliderInput(inputId = "labsize",
                                      label = "Label Size",
                                      min = 5,
                                      max = 20,
                                      value = 0,
                                      step = 1),
                          sliderInput(inputId = "nudge",
                                      label = "Nudge Labels",
                                      min = 0,
                                      max = 3,
                                      value = 0.4,
                                      step = 0.1),
                          selectInput(inputId = "family",
                                      label = "Font Family",
                                      selected = "mono",
                                      choices = c("sans", "mono", "new")),
                          sliderInput(inputId = "namesize",
                                      label = "Name Size",
                                      min = 1,
                                      max = 15,
                                      value = 0.4,
                                      step = 0.1)),
                        mainPanel(
                          p("Try download and browse this file to test MiVector: "),
                          p("Output:"),
                          plotOutput("distPlot")
                        )
                      )
             ),
             tabPanel("Option 2",
                      p("Create GenBank files to visualize. In progress.."))
  )
)


server <- function(input, output,session) {

  fileOptions <- reactiveValues()

  observeEvent(input$file1, {
    r <- get_gbkfeatures(filepath = input$file1$datapath)$sortInfo()
    print(r)
    fileOptions$currentOptions = as.list(r$label)
  })


  output$checkbox<-renderUI({
    checkboxGroupInput("rmfeatures","Remove Labels:", choices = fileOptions$currentOptions)
  })

  output$distPlot <- renderPlot({

    req(input$file1)

    plasmid <- parse_plasmid(file = input$file1$datapath)

    if(length(input$rmfeatures)>0) {
      get_gbkfeatures(filepath = input$file1$datapath)$edit_gbk(rm_feat = input$rmfeatures)
      plasmid <- parse_plasmid("Data/newgbk.gb")
    }

    render_plasmap(plasmid,
                   rotation = input$rotation,
                   plasmid_name = input$plasname,
                   label_size = input$labsize,
                   name_size = input$namsize,
                   font_family = input$family,
                   bp_count = FALSE,
                   label_nudge = input$nudge)
  }, width = 1000, heigh = 1000)
}

shinyApp(ui, server)
