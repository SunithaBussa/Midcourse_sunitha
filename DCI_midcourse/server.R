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
  
  #plot map
  output$mymap <- renderLeaflet({
  
    payment_geom_summary_w <- payment_geom_summary %>%
          filter(dos_year == input$summary_year) %>%
          filter(dos_month == input$summary_month_slider)
    
      leaflet(data = payment_geom_summary_w) %>%
      addTiles() %>%
      setView(-79.96,40.68,zoom=9) %>%
     
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
     
     #plot box plots based on year and month
        box_pl<-payment_type_dist_shiny %>% 
                filter(dos_year == input$summary_year & dos_month == input$summary_month_slider) %>% 
                ggplot(aes(y = payment,x = payment_type,fill=payment_type)) +
                geom_boxplot(alpha=0.4)+
                theme_classic() +
                labs(x="Payment type", y = "Payment",
                title = paste("Distribution by Payment Types"))+
                theme(axis.text.x = element_text(angle=45,hjust=1),legend.title = element_blank())
      
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
            labs(x="Logged payments",y="Frequency",title =paste("Distribution by Payment Types"))+
            theme_classic()
      
        ggplotly(pl) %>% 
          layout(legend = list(y=-0.06,orientation = 'h'))
    })
    
    #value box top first
    output$vbox1 <- renderValueBox({
      valueBox(value=tags$p(paste("$",dci_data_shiny %>% 
                                     select(dos_year,payment) %>% 
                                     filter(dos_year==input$summary_year) %>% 
                                    summarise(formatC(as.numeric(sum(payment)), format="f", digits=2, big.mark=","))
                                     ),style = "font-size: 50%;" ),
                
                  subtitle = paste("Total Payments for ",input$summary_year),color="fuchsia")
        
    })
    
    #value box top second
    output$vbox2 <- renderValueBox({
      valueBox(value=tags$p(paste("$",dci_data_shiny %>% 
                                    select(dos_year,payment,part_a,part_b) %>% 
                                    filter(dos_year==input$summary_year) %>% 
                                    summarise(formatC(as.numeric(sum(part_a)), format="f", digits=2, big.mark=","))
                                   ),style = "font-size: 50%;" 
                            ),
               
               subtitle = paste("Part A payments for ",input$summary_year),color="orange")
      
    })
    
    #value box top third
     
    output$vbox3 <- renderValueBox({
      valueBox(value=tags$p(paste("$",dci_data_shiny %>% 
                                    select(dos_year,payment,part_a,part_b) %>% 
                                    filter(dos_year==input$summary_year) %>% 
                                    summarise(formatC(as.numeric(sum(part_b)), format="f", digits=2, big.mark=","))
                                  ),style = "font-size: 50%;" ),
               
               subtitle = paste("Part B payments for ",input$summary_year),color="teal")
      
    })
    
    #Features /labs
    output$features <- renderPlotly({
      
     features_pl<- dci_data_shiny %>% 
                   filter('input$sel_features' > 0) %>% 
                   ggplot( aes_string(y='payment',x=input$sel_features) ) +
                   geom_point(alpha=0.2) + geom_smooth(method = 'lm') +
                   stat_binhex() +
                   scale_x_log10() +
                   scale_y_log10() +
                   labs(x=input$sel_features, y = "payment", title = paste("Payment Vs ",input$sel_features)) 
  
     ggplotly(features_pl)
       
     
   
     
        })
    
    #Correlation Plot
    output$corr_plot <- renderPlot({
      
      num_columns <- c("payment","hgb","tsat","ferr","albumin","pth","ca","cca","ph","k","urr","ktv")
      corrs<-dci_data_shiny %>% select(num_columns)  %>% 
        cor()
      
      
      corrplot(corrs,type = "upper",order = "hclust",
               tl.col="black",tl.srt=45)
      
    })
    
    
    #Raw Data
    output$raw_data_table <- DT:: renderDataTable({
      
      DT::datatable( dci_data_shiny %>% 
                       select(dos_month,dos_year,location_id,patient_id,payment,part_a,part_b,inpatient,outpatient_dialysis,modality) %>% 
                       filter(dos_month==input$data_month_slider &
                                dos_year==input$data_year)
                     )
      
    })
    
    #Locations bar charts
    output$payments_by_locPlot <- renderPlotly({
  
                   loc_plt <- payment_geom_summary %>% 
                              arrange(desc(totalpayments)) %>% 
                              filter(dos_year==input$loc_year & dos_month == input$loc_month_slider) %>% 
                              plot_ly( 
                                      source="myClickSource",
                                      x = ~location_id,
                                      y = ~avg_pay,
                                      type = "bar"
                                     ) 
               
                ggplotly(loc_plt)
    })
    
    SelectedBar <- reactiveVal(NULL)
    
    observe({
      myClicks <- event_data("plotly_click", source = "myClickSource")
      req(myClicks)
      print(myClicks)
      SelectedBar(toString(myClicks$x))
    })
    
    output$pay_detail_locTable <-renderDataTable({
      
      
      DT::datatable(  
                     
                    data<-as.data.frame( dci_data_shiny[which(dci_data_shiny$location_id == SelectedBar() & dci_data_shiny$dos_year==input$loc_year & dci_data_shiny$dos_month ==input$loc_month_slider ),
                                    names(dci_data_shiny) %in% c("location_id","patient_id","payment","part_a","part_b","inpatient","outpatient_dialysis")])
                    
                     
                    )
      
     # payment_geom_summary
      
    })
    
})
