#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
options(scipen = 999)
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  output$mymap <- renderLeaflet({
  
    payment_geom_summary_w <- payment_geom_summary %>%
          filter(dos_year == input$summary_year) %>%
          filter(dos_month == input$summary_month_slider)
    
      leaflet(data = payment_geom_summary_w) %>%
      addTiles() %>%
     
      addMarkers(
        ~ longitude,
        ~ latitude,
         
        popup = paste(tags$b("Clinic Name:"), payment_geom_summary_w$short_name, "<br>",
                      tags$b("Clinic ID:"), payment_geom_summary_w$location_id, "<br>",
                      tags$b("Address:"), payment_geom_summary_w$location_address_1, "<br>",
                      tags$b("Total Payments:"), paste("$",round(payment_geom_summary_w$totalpayments,digits = 2)), "<br>",
                      tags$b("Avg Payments:"), paste("$",round(payment_geom_summary_w$avg_pay,digits=2)), "<br>",
                      tags$b("Minimum Payments:"),paste("$",round(payment_geom_summary_w$min_pay,digits=2)) , "<br>",
                      tags$b("Maximum Payments:"), paste("$",round(payment_geom_summary_w$max_pay,digits=2)), "<br>",
                      tags$b("Number of Patients:"), payment_geom_summary_w$total_patients, "<br>"
                      ),
        label = ~ as.character(payment_geom_summary_w$short_name)
      )
      })
  

    output$distPlot <- renderPlotly({
      #plot histogram based on year and month
       
      #  p<- ggplot(dci_data_shiny,aes(x=payment,y=..density..)) +
        #    geom_histogram(bins=40,binwidth = 0.05,fill = "black",color="black",alpha=0.2) +
       #     scale_x_log10()+
          #  geom_density(color = "blue")+
         #   labs(x="Logged payments",y="Frequency",title = "Total Payments distribution") +
           # theme_classic()
       
         #ggplotly(p) 
      
      box_pl<-payment_type_dist_shiny %>% 
        filter(dos_year == input$summary_year & dos_month == input$summary_month_slider) %>% 
        ggplot(aes(y = payment,x = payment_type,fill=payment_type)) +
        geom_boxplot(alpha=0.4)+
        #  scale_y_log10() +
        theme_classic() +
        labs(x="Payment type", y = "Payment",
             title = "Payment distribution by payment types")
      
      ggplotly(box_pl)
        
        

    })
  
    output$payment_type_distPlot <- renderPlotly({
      #plot histogram across payment_types for each year and month
      
        pl<-dci_data_shiny %>% 
            select(dos_year,dos_month,location_id,payment,part_a,part_b_dme,part_b_phys,part_b)%>% 
            pivot_longer(payment:part_b,names_to="payment_type",values_to = "payment") %>% 
            filter(dos_year==input$summary_year & dos_month==input$summary_month_slider) %>% 
            ggplot( aes(x=payment,fill=payment_type,color= payment_type)) +
            geom_histogram(bins= 40,binwidth = 0.05,alpha=0.3,position = "identity") +
            scale_x_log10() +
            geom_vline(aes(xintercept = mean(payment,na.rm=T)),color = "red", linetype = "dashed",size = 1) +
            labs(x="Logged payments",y="Frequency",title =paste("Payment distribution across payment types for year",input$summary_year))+
            theme_classic()
      
        ggplotly(pl) %>% 
          layout(legend = list(y=-0.06,orientation = 'h'))
    })
    
    output$vbox1 <- renderValueBox({
      valueBox(value=tags$p(paste("$",dci_data_shiny %>% 
                 select(dos_year,payment) %>% 
                 filter(dos_year==input$summary_year) %>% 
                 summarise(round(sum(payment),digits = 2))),style = "font-size: 50%;" ),
                
                  subtitle = paste("Total Payments for ",input$summary_year),color="black")
        
    })
    
    #Features
    output$features <- renderPlotly({
      
     features_pl<- dci_data_shiny %>%
                    mutate(payment = payment,xvariable=input$sel_features) %>%
                    filter(xvariable!=0) %>%
                             ggplot(aes(x=xvariable,y=payment) ) +
                   geom_point(alpha=0.4) + geom_smooth(method = 'lm') +
                   #scale_x_log10() +
                   #scale_y_log10() +
                   labs(x=input$sel_features, y = "payment", title = paste("Payment Vs ",input$sel_features))
       
      ggplotly(features_pl)
   
     
        })
    
    output$raw_data_table <- DT:: renderDataTable({
      
      DT::datatable( dci_data_shiny %>% 
                       select(dos_month,dos_year,location_id,patient_id,payment,part_a,part_b,part_b_dme,part_b_phys) %>% 
                       filter(dos_month==input$summary_month_slider &
                                dos_year==input$summary_year)
                     )
      
    })
    
    
    
    
})
