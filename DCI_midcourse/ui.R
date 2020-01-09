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
dbHeader$children[[3]]$children <- tags$h3(tags$img(src='kidney-bean.png',height='60',width='100'),"Welcome to Dialysis Clinic Incorporation!",align = "middle")
dbHeader$children[[2]]$children <-  tags$a(href='http://www.dciinc.org',
                                           tags$img(src='DCI_logo.png',height='40',width='190'))

shinyUI(
  
  dashboardPage(
    #dashboardHeader(title = "Dialysi Clinic Incorporation"),
   
    dbHeader,
    dashboardSidebar(
      sidebarMenu(
        menuItem("Introduction",tabName = "introduction", icon = icon("user-md",class= NULL, lib="font-awesome")),
          menuSubItem("Dashboard Finance", tabName = "finance"),
          menuSubItem("Dashboard Sales", tabName = "sales"),
        menuItem("Detailed Analysis"),
        menuItem("Raw Data")
      )
    ),
    dashboardBody(
      
      tabItems(
        tabItem(tabName = "introduction",
                fluidRow(
                  box(h2("first tab"))
                )),
        tabItem(tabName = "finance",
                h1("Finance Dashboard")),
        tabItem(tabName = "sales",
                h2("Sales Dashboard"))
      )
    )
    
  ) 
  
)
