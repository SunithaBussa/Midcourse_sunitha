#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)
 
dbHeader <- dashboardHeader()
dbHeader$children[[3]]$children <-tags$p( tags$h2(tags$img(src='kidney-bean.png',height='40',width='50'),tags$b("Welcome to Dialysis Clinic Incorporation"),align = "middle"),style = "font-size:50%;")
dbHeader$children[[2]]$children <-  tags$a(href='http://www.dciinc.org',
                                           tags$img(src='DCI_logo.png',height='40',width='190'))

shinyUI(
  
  dashboardPage(
    #dashboardHeader(title = "Dialysi Clinic Incorporation"),
   
    dbHeader,
    
    #Side bar
    dashboardSidebar(
      sidebarMenu(id = "sidebarmenu",
        menuItem("Introduction",tabName = "introduction", icon = icon("user-md",class= NULL, lib="font-awesome")),
        
          menuSubItem("Payment Summary", tabName = "summary",icon = icon("money-bill-alt")),
          conditionalPanel("input.sidebarmenu=='summary'",
                           selectInput("summary_year","Pick Year",choices = c(2017,2018)),
                           sliderInput("summary_month_slider","Pick Month",1,12,1)),
        
          menuSubItem("Location Payments", tabName = "locations_pay",icon = icon("location-arrow")),
                  conditionalPanel("input.sidebarmenu=='locations_pay'",
                         selectInput("loc_year","Pick Year",choices = c(2017,2018)),
                         sliderInput("loc_month_slider","Pick Month",1,12,1)),
        
        menuItem("Modalities",tabName = "modality",icon = icon("procedures")),
        
        menuItem("Labs",tabName = "feature_tab",icon = icon("diagnoses")),
          conditionalPanel("input.sidebarmenu=='feature_tab'",
                         selectInput("sel_features","Select Feature",choices = features_shiny_df$`features_shiny[37:47]`)
                          ) ,
        
        menuItem("Raw Data",tabName = "data",icon = icon("database")),
          conditionalPanel("input.sidebarmenu=='data'",
                         selectInput("data_year","Pick Year",choices = c(2017,2018)),
                         sliderInput("data_month_slider","Pick Month",1,12,1)),
        
        menuItem("Key Words",tabName = "keywords",icon = icon("key"))
      )
    ),
    
    
    #body
    dashboardBody(
      
      tabItems(
        tabItem(tabName = "introduction",
             
                fluidRow(
                  
                  column(6,h2("Dialysis Claims Data Analysis"),
                         
                         tags$p(tags$b("What is Dialysis?:")),
                         tags$p("Dialysis is a treatment that replaces the work of your own kidneys to clear wastes and extra fluid from your blood. This is done using a special filter called a dialyzer or artificial kidney. Your blood travels through plastic tubing to the dialyzer, where it is cleaned and then returned to you. At the beginning of each treatment, two needles are placed into your access. These needles are connected to the plastic tubing that carries your blood to the dialyzer. Only a small amount of blood is out of your body at any one time. The dialysis machine pumps your blood through the dialysis system and controls the treatment time, temperature, fluid removal and pressure.
                                  This basic process is the same for home hemodialysis, except that you and a care partner are trained to do your treatment at home."),
                         tags$p("This application explores a dataset from Dialysis Clinic Incorportion's patient cliams. Data from 2017 to 2018 from single ESCO(ESRD Seamless Care Organizations ) has been used in this analysis for simplicity purpose. The goal of the exploration is to understand the distribution of payments among diffent payment types, modalities, features, locations and patients. "),
                         ),
                  
                  column(6,img(src='patient.png', width='500',height='400' ))
                        )
                ),
        tabItem(tabName = "summary",
                
                tags$head(tags$style(HTML(".small-box {height: 60px}"))),
                
                #header and value boxes
                     fluidRow(
                              column(6,h2("Payment Summary Analysis")),
                              column(2,offset=0.5,valueBoxOutput("vbox1",width=NULL)),
                              column(2,offset=0.5,valueBoxOutput("vbox2",width=NULL)),
                              column(2,offset=0.5,valueBoxOutput("vbox3",width=NULL))
                             ),
               #Map
                    fluidRow(
                             box(width = 12, solidHeader = TRUE,leafletOutput("mymap"))
                             ),
               
              #Boxplots and Histogram
                    fluidRow(
                             column (6,height='10px',box(width=100, solidHeader = TRUE, plotlyOutput("distPlot"))),
                             column(6,height='10px',box(width=500, solidHeader = TRUE, plotlyOutput("payment_type_distPlot")))
                            )
                ),
        
        # Locations bar graph and data
                tabItem(tabName = "locations_pay",
                fluidRow(height=200,
                        column(width = 12,plotlyOutput("payments_by_locPlot")),
                        column(width = 12,dataTableOutput("pay_detail_locTable"))
                        )
                ),
        tabItem(tabName = "modality",
                h1("Modality Analysis")
                ),
        
        #Features
        tabItem(tabName = "feature_tab",
                column(6,height='50px',box(width=500, solidHeader = TRUE, plotlyOutput("features"))),
                column(6,height='50px',box(width=500, solidHeader = TRUE, plotOutput("corr_plot")))
                  
                  
                ),
        tabItem(tabName = "data",
                h1("Raw Data"),
                fluidRow(
                  box(width = 12, status='primary',
                      'Click on the column to sort.',
                      DT::dataTableOutput("raw_data_table"))
                )),
        tabItem(tabName = "keywords",
                tags$h2("Key Words:"),
                tags$p(strong("Part A"),": Medicare Part A is hospital insurance. Part A generally covers inpatient hospital stays, skilled nursing care, hospice care, and limited home health-care services."),
                tags$p(strong("Part B"),": Medicare Part B is medical insurance. Part A generally covers services like flushots, supplies,Physical therapy etc."),
                tags$p(strong("Part B DME"),":Medicare Part B covers (Durable Medical Equipment ) like walkers, wheelchairs, or hospital beds"),
                tags$p(strong("Part B phy"),":Medicare Part B covers outpatient therapy, including physical therapy (PT), speech-language pathology (SLP), and occupational therapy (OT)"),
                tags$p(strong("Hemo In-Center(HIC)"),": In-center hemodialysis is when a person goes to a dialysis center for their hemodialysis treatments. Hemodialysis is a treatment that filters the blood of wastes and extra fluid when the kidneys are no longer able to perform this function."),
                tags$p(strong("Peritoneal dialysis (PD)")," :PD is a treatment that uses the lining of your abdomen (belly area), called your peritoneum, and a cleaning solution called dialysate to clean your blood. Dialysate absorbs waste and fluid from your blood, using your peritoneum as a filter. One benefit of PD is that it is not done in a dialysis center. You can do your PD treatments any place that is clean and dry."),
                tags$p(strong("Hemo Home(HH)"),": HH is a treatment that uses the lining of your abdomen (belly area), called your peritoneum, and a cleaning solution called dialysate to clean your blood. Dialysate absorbs waste and fluid from your blood, using your peritoneum as a filter. One benefit of PD is that it is not done in a dialysis center. You can do your PD treatments any place that is clean and dry."),
                tags$p(strong("hgb"),": Hemoglobin Range(10-11)"),
                tags$p(strong("ferr"),": Ferritin/Iron >100 ng/mL"),
                tags$p(strong("albumin"),": Serum albumin > 4.0 g/dl"),
                tags$p(strong("pth"),": Parathyroid harmone Range(10-65)"),
                tags$p(strong("ca"),": Calcium(3.0-5.5)"),
                tags$p(strong("cca"),": Serum corrected calcium(8-9)"),
                tags$p(strong("ph"),": Acid balance <7.30"),
                tags$p(strong("k"),": Potassium Range(3.5-5.5)"),
                tags$p(strong("Urr"),": Urea reduction Ratio > 65%"),
                tags$p(strong("ktv"),": Clearance * times / volume >2")
                
        )
      )
    )
    
  ) 
  
)
