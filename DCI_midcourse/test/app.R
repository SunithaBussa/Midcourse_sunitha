library(data.table)
library(plotly)
library(shiny)
library(shinydashboard)

ui <- dashboardPage(
    dashboardHeader(),
    dashboardSidebar(),
    dashboardBody(plotlyOutput("myPlot"),
                  dataTableOutput("myTable"))
)

server <- function(input, output) {
    
    portfolio = c(100, 100, 100, 100)
    
    my_portfolio <- data.table(EuStockMarkets)
    my_portfolio[, Date := seq(as.Date('2011-01-01'), as.Date('2016-02-03'), by = 1)]
    my_portfolio[, R_DAX := portfolio[1] * c(NA, diff(DAX))]
    my_portfolio[, R_SMI := portfolio[2] * c(NA, diff(SMI))]
    my_portfolio[, R_CAC := portfolio[3] * c(NA, diff(CAC))]
    my_portfolio[, R_FTSE := portfolio[4] * c(NA, diff(FTSE))]
    my_portfolio[, Total_Return := R_DAX + R_SMI + R_CAC + R_FTSE]
    
    plot_subset <- my_portfolio[2:100]
    
    output$myPlot <- renderPlotly({
        plot_ly(
            plot_subset,
            source = "myClickSource",
            x =  ~ Date,
            y =  ~ Total_Return,
            type = "bar"
        )
    })
    
    SelectedBar <- reactiveVal(NULL)
    
    observe({
        myClicks <- event_data("plotly_click", source = "myClickSource")
        req(myClicks)
        print(myClicks)
        SelectedBar(as.Date(myClicks$x))
    })
    
    output$myTable <- renderDataTable({
        plot_subset[Date %in% SelectedBar()]
    })
    
}

shinyApp(ui, server)
