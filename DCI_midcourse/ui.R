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
dbHeader$children[[3]]$children <- tags$h2(tags$img(src='kidney-bean.png',height='60',width='100'),"Welcome to Dialysis Clinic Incorporation",align = "middle")
dbHeader$children[[2]]$children <-  tags$a(href='http://www.dciinc.org',
                                           tags$img(src='DCI_logo.png',height='40',width='190'))

shinyUI(
  
  dashboardPage(
    #dashboardHeader(title = "Dialysi Clinic Incorporation"),
   
    dbHeader,
    dashboardSidebar(
      sidebarMenu(id = "sidebarmenu",
        menuItem("Introduction",tabName = "introduction", icon = icon("user-md",class= NULL, lib="font-awesome")),
          menuSubItem("Summary", tabName = "summary"),
          conditionalPanel("input.sidebarmenu=='summary'",
                           sliderInput("summary","pick year",2016,2020,1)),
          menuSubItem("Detail", tabName = "detail"),
        menuItem("Modalities",tabName = "modality"),
        menuItem("Features",tabName = "feature"),
        menuItem("Raw Data",tabName = "data")
      )
    ),
    dashboardBody(
      
      tabItems(
        tabItem(tabName = "introduction",
                fluidRow(
                  box(h2("first tab"))
                )),
        tabItem(tabName = "summary",
                h1("Summary Analysis"),
                h2("try")
                ),
        tabItem(tabName = "detail",
                h1("Detail Analysis")),
        tabItem(tabName = "modality",
                h1("Modality Analysis")),
        tabItem(tabName = "feature",
                h1("Features Analysis")),
        tabItem(tabName = "data",
                h1("Raw Data"))
      )
    )
    
  ) 
  
)
