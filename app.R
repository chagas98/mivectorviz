#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

#Load packages
library(shiny)
library(reticulate)
library(bslib)
library(ggfittext)
library(plasmapR)

#Create Virtual Environment in Shiny Cloud
reticulate::virtualenv_create("python35_env", python = "python3")
reticulate::virtualenv_install("python35_env", packages = c("pandas", "numpy", "biopython"))
reticulate::use_virtualenv("python35_env", required = TRUE)

#To avoid shiny deployment errors
source("FUNS.R")

#Setting up the interface theme
my_theme <- bslib::bs_theme(bootswatch = "flatly",
                            base_font = font_google("Righteous"))

#UI - Define Input/Outputs and Web app organization
ui <- fluidPage(
  theme = my_theme,
  navbarPage("MiVector!",
             tabPanel("About",
                      p("Description - Go to Option 1")),
             tabPanel("Option 1",
                      sidebarLayout(
                        sidebarPanel(
                          fileInput("file1",
                                    "Choose GenBank File",
                                    accept = c(".gb", ".gbk")),
                          textInput(inputId = "plasname",
                                    label = "Plasmid Name"),
                          selectInput(inputId = "colorscal",
                                      label = "Colour Scales",
                                      choices = c("Sequential" = "seq",
                                                  "Diverging" = "div",
                                                  "Qualitative" = "qual")),
                          sliderInput(inputId = "colpalette",
                                      label = "Palette",
                                      min = 1,
                                      max = 20,
                                      value = 1,
                                      step = 1),
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
                          p("Test MiVectorViz with this example file (Download and Browse): "),
                          p(a(href="petm20.gb", "GenBank Example File", download=NA, target="_blank")),
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

  #Create ReactiveValues for choices in output$checkbox - the application will read the file and get the features
  fileOptions <- reactiveValues()

  #Since the file uploaded, the python function will collect the features info and print in the sidebar.
  observeEvent(input$file1, {

    r <- get_gbkfeatures(filepath = input$file1$datapath)$sortInfo()

    fileOptions$currentOptions = as.list(r$label)
    }
  )

  #The renderUI will plot the labels list where the user can remove them for visualization
  output$checkbox<-renderUI({
    checkboxGroupInput("rmfeatures","Remove Labels:", choices = fileOptions$currentOptions)
    }
  )

  output$distPlot <- renderPlot({

    #Run when file is uploaded
    req(input$file1)

    # Define plasmid
    plasmid <- plasmapR::parse_plasmid(file = input$file1$datapath)

    # The code produce a new genbank file when edit the labels list and turn the new plasmid value as well.
    if (length(input$rmfeatures)>0) {
      get_gbkfeatures(filepath = input$file1$datapath)$edit_gbk(rm_feat = input$rmfeatures)

      plasmid <- parse_plasmid("Data/newgbk.gb")
    }

    #Plot for each edit
    plasViz <-  render_plasmap(plasmid,
                rotation = input$rotation,
                plasmid_name = "oi",#input$plasname,
                label_size = input$labsize,
                name_size = input$namesize,
                font_family = input$family,
                bp_count = FALSE,
                zoom_y = 3,
                label_nudge = input$nudge)

    plasViz + ggplot2::scale_fill_brewer(palette = input$colpalette, type = input$colorscal)

    }, width = 800, heigh = 800)
  }

shinyApp(ui, server)
