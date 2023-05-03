#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# Define server logic required to draw a histogram
function(input, output, session) {
  #-------- plot map -----------
  output$mymap <- renderLeaflet({
    
    #Adding pal response
    pal <- colorNumeric("YlGnBu", domain = year_data()$mean_total_paid)
    pop <- paste("Locality:", ny_borough$boro_name, "<br>",
                 "Mean Total Paid:", year_data()$mean_total_paid, "<br>")
    
    leaflet() %>% 
      addProviderTiles("CartoDB") %>%   
      addPolygons(data = ny_borough,
                  color = "#BDBDBD",
                  fillColor = ~pal(year_data()$mean_total_paid), 
                  fillOpacity = 1, popup = pop
      ) %>%
      addLegend(data = year_data(),
                pal = pal, 
                values = year_data()$mean_total_paid, 
                title = "Mean Total Paid",
                position = "topleft") %>%
      setView(lng = -73.94, lat = 40.70, zoom = 10)
    
  })
  
  #-------- plot bar chart -----------
  
  # Create a reactive object that filters the data based on year selection
  filtered_data <- reactive({
    data %>% filter(`Fiscal Year` == input$year, `Agency Name` == input$agency)
  })
  # Create a reactive object that summarizes the data by borough
  summarized_data <- reactive({
    filtered_data() %>% group_by(`Work Location Borough`) %>%
      summarize(mean_base_salary = mean(`Base Salary`))
  })
  # Create the bar chart
  output$barplot <- renderPlotly({
    # Create the plot using plotly
    plot_ly(summarized_data(), x = ~`Work Location Borough`, y = ~mean_base_salary, type = "bar",
            marker = list(color = "steelblue"), name = "Mean Base Salary") %>%
      layout(title = paste("Mean Base Salary by Work Location Borough (", input$year, ")"),
             xaxis = list(title = "Work Location Borough"),
             yaxis = list(title = "Mean Base Salary"),
             margin = list(t = 80))
  })
  
  #-------- plot Line Chart -----------
  
  # Create a reactive object that filters the data based on year selection
  year_data <- reactive({
    map_data %>% filter(`Fiscal Year` == input$map_year)
  })
  
  # Create reactive object for selected location data
  data_subset <- reactive({
    locations <- input$location
    if (is.null(locations) || locations == "") {
      # No locations selected, return empty data frame
      return(data.frame())
    } else if (length(locations) == 1) {
      # Single location selected, filter by that location
      line_data %>% filter(`Work Location Borough` == locations)
    } else {
      # Multiple locations selected, filter by all selected locations
      line_data %>% filter(`Work Location Borough` %in% locations)
    }
  })
  
  # Display line chart for OT hours by year when a location is selected
  output$ot_plot <- renderPlotly({
    if (nrow(data_subset()) == 0) {
      # Return empty plot with axis labels
      plot_ly() %>%
        layout(title = "Mean OT Hours by Location",
               xaxis = list(title = "Fiscal Year", range = c(2015, 2022)),
               yaxis = list(title = "Mean OT Hours", range = c(0, 300)),
               margin = list(t = 50)
        )
    } else {
      plot_ly(data_subset(), x = ~`Fiscal Year`, y = ~mean_OT_Hours, color = ~`Work Location Borough`) %>%
        add_lines() %>%
        layout(title = "Mean OT Hours by Location",
               xaxis = list(title = "Fiscal Year"),
               yaxis = list(title = "Mean OT Hours", range = c(0, max(data_subset()$mean_OT_Hours)),
                            margin = list(t = 60))
        )
    }
  })
  observeEvent(input$reset, {
    updateSelectInput(session, "location", selected = "All")
  })
  
  #-------- plot top 20 agency in all borough -----------
  
  output$flipbarPlot1 = renderPlot({
    
    # Plot top 20 Agency Names with highest mean OT Hours
    ggplot(data = agency_data) +
      geom_bar(aes(x = reorder(`Agency Name`, mean_OT_Hours), y = mean_OT_Hours),
               stat = "identity") +
      labs(title = "Top 20 Agencies with Highest Mean OT Hours",
           x = "Agency Name",
           y = "Mean OT Hours") +
      coord_flip()
  })
  
  #-------- plot top 20 agency freq graph for each borough -----------
  
  output$flipbarPlot2 = renderPlot({
    agency_data <- data %>% 
      group_by(`Agency Name`) %>% 
      summarize(mean_OT_Hours = mean(`OT Hours`), count = n()) %>% 
      top_n(20, mean_OT_Hours)
    # use top 20 causes to filter original table with borough column: 
    df_top <- agency_data %>% 
      arrange(mean_OT_Hours) 
    
    df <- data %>%
      # use top 20 overall result to filter the original table:
      semi_join(., df_top, by="Agency Name") %>%
      group_by(`Work Location Borough`, `Agency Name`) %>%
      summarise(count=n())%>%
    # reorder agency name levels for desirable order in bar chart display:
    mutate(`Agency Name` = factor(`Agency Name`, levels=df_top$`Agency Name`)) 
    
    df_boro_tot <- df %>%
      group_by(`Work Location Borough`) %>%
      summarise(total = sum(count))
    
    # calculate ratio for percentage axis display:
    df <- df %>%
      left_join(., df_boro_tot, by="Work Location Borough") %>%
      mutate(ratio = count / total) %>%
      select(-count, -total) 
    
    
    ggplot(data = df) +
      geom_bar(aes(x=`Agency Name`, y=ratio, fill=`Work Location Borough`), 
               width=0.5, stat='identity', show.legend = F) +
      coord_flip() +
      facet_grid(.~`Work Location Borough`) +
      labs(title='Freq of Top 20 Agencies with Highest Mean OT Hours in Different Location',
           x='Top 20 Agencies with Highest Mean OT Hours',
           y= 'Percent') + 
      scale_fill_brewer(palette = 'Set1') + 
      scale_y_continuous(labels = scales::percent_format())
  })
  
  # Create a reactive object that get the top 20 agency with highest OT Hours
  summarized_data_2 <- reactive({
    top_20_data %>%
      group_by(`Agency Name`, `Work Location Borough`) %>% 
      summarize(mean_OT_Hours = mean(`OT Hours`))
  })
  
  #-------- plot network Visualization -----------
  
  # Create the network visualization
  output$network <- renderVisNetwork({
    # Create a nodes data frame with unique agency names and boroughs
    nodes <- data.frame(id = unique(summarized_data_2()$`Agency Name`), 
                        label = unique(summarized_data_2()$`Agency Name`),
                        title = "Agency",
                        name = unique(summarized_data_2()$`Agency Name`),
                        stringsAsFactors = FALSE)
    nodes <- rbind(nodes, 
                   data.frame(id = unique(summarized_data_2()$`Work Location Borough`), 
                              label = unique(summarized_data_2()$`Work Location Borough`), 
                              title = "Borough",
                              name = unique(summarized_data_2()$`Work Location Borough`),
                              stringsAsFactors = FALSE))
    
    # Set node colors based on working location borough using RColorBrewer's "Set2" palette
    n_boroughs <- length(unique(summarized_data_2()$`Work Location Borough`))
    node_colors <- data.frame(id = unique(summarized_data_2()$`Work Location Borough`), color = brewer.pal(n_boroughs, "Set2"))
    nodes <- merge(nodes, node_colors, by = "id", all.x = TRUE)
    
    
    # Create an edges data frame with connections between agency names and boroughs
    edges <- summarized_data_2() %>% 
      filter(`Work Location Borough` %in% nodes$id) %>%
      mutate(from = `Agency Name`, to = `Work Location Borough`)
    
    # Create the visNetwork object with nodes and edges
    visNetwork(nodes, edges, width = "100%") %>%
      visNodes(shape = "dot", color = list(background = nodes$color),
               label = nodes$label, font = list(size = 20, face = "bold", color = 'white'),
               title = nodes$title, size = 50) %>%
      visHierarchicalLayout(direction = "LR")%>%
      visPhysics(stabilization = TRUE)
  })
  
}

