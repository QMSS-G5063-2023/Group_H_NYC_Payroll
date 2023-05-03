
navbarPage('NYC Payroll', theme = shinytheme("superhero"),
           tabPanel('Introduction',
                    div(
                      class='coverDiv',
                      tags$head(includeCSS('styles.css')),
                        absolutePanel(fixed = TRUE, draggable = FALSE, 
                                      top = 60, left = 50, right = 'auto', bottom = 'auto',
                                      width = 550, height = 'auto', 
                                      div( class = 'coverTextDiv',
                                           h1('Citywide Payroll Data (Fiscal Year) Visulization'),
                                           h3(HTML('<em>Teng-Shao Lu, HongYu Ye</em>')),
                                           h4("Because the public is interested in how the City budget
                                              is spent on wages and overtime for all City employees.
                                              So this works is to show you how the city's financial 
                                              resources are allocated and how much of the city's 
                                              budget goes to overtime. You can explore the data 
                                              through various interactive map tools."),
                                           br()
                                      )
                        )
                    )
           ),
    # First tab: "Map"
    tabPanel("Mean Total Paid",
             fluidRow(
               column(width = 10,
                      offset = 2,
                      titlePanel(HTML("<h1 style='text-align:top center;font-weight:bold;'>Do Mean Total Paid Differ in Different NYC Boroughs?</h1>"))
               )
             ),
             fluidRow(
               column(width = 10,
                      offset = 2,
                      p(style = "font-size: 16px; text-align:top center;font-family: Georgia, serif;",
                        "This Leaflet Map enables you to access a map of New York City and investigate the mean total paid in different boroughs based on the year selection.",
                        br(),
                        "We calculate the mean total paid as the sum of Regular Gross Paid, Total OT Paid and Total Other Pay. From 2015 to 2022, mean total paid in the Manhattan borough is higher than in other boroughs.
                        In addition, Brooklyn has the lowest mean total paid in history."
                      )
               )
             ),
             fluidRow(
               column(width = 4, offset = 1,
                      sliderInput("map_year", "Choose a year:",
                                  min = min(data$`Fiscal Year`), max = max(data$`Fiscal Year`), value = min(data$`Fiscal Year`))
               )
             ),
             fluidRow(
               column(width = 12,
                      leafletOutput("mymap")
               )
             ),
             fluidRow(
               column(width = 10,
                      offset = 2,
                      p(style = "font-size: 14px; text-align:center;",
                        "Note: The data used in this map is based on publicly available information from ",
                        a("New York City's Open Data Portal", href = "https://data.cityofnewyork.us/City-Government/Citywide-Payroll-Data-Fiscal-Year-/k397-673e", target="_blank"),
                        "."
                      )
               )
             )
    ),
    tabPanel("Agencies' Salaries",
             fluidRow(
               column(width = 10,
                      offset = 2,
                      titlePanel(HTML("<h1 style='text-align:top center;font-weight:bold;'>What is the Mean Base Salary for Each Angency in Selected Year?</h1>"))
               )
             ),
             fluidRow(
               column(width = 10,
                      offset = 2,
                      p(style = "font-size: 16px; text-align:top center; font-family: Georgia, serif;",
                        "Select different years and agencies to see the mean base salary in five different boroughs."
                      )
               )
               ),
             sidebarLayout(
               sidebarPanel(
                 selectInput("year",
                             "Select a year:",
                             choices = sort(unique(data$`Fiscal Year`))),
                 selectInput("agency",
                             "Select an agency:",
                             choices = sort(unique(data$`Agency Name`))),
                 br(),
                 p(style = "font-size: 14px;",
                   "Note: Some types of agency may only be available in specific boroughs.")
               ),
               
               mainPanel(
                 plotlyOutput("barplot")
               )
             ),
             fluidRow(
               column(width = 10,
                      offset = 2,
                      p(style = "font-size: 14px; text-align:center;",
                        "Note: The data used in this bar chart is based on publicly available information from ",
                        a("New York City's Open Data Portal", href = "https://data.cityofnewyork.us/City-Government/Citywide-Payroll-Data-Fiscal-Year-/k397-673e", target="_blank"),
                        "."
                      )
               )
             )
    ),
    
    
    tabPanel("OT Hours Change",
             fluidRow(
               column(width = 10,
                      offset = 2,
                      titlePanel(HTML("<h1 style='text-align:top center;font-weight:bold;'>How do OT Hours Change by Boroughs Over Years?</h1>"))
               )
             ),
             fluidRow(
               column(width = 10,
                      offset = 2,
                      p(style = "font-size: 16px; text-align:top center;font-family: Georgia, serif;",
                        "This is the Line Chart tab where you can view a line chart of payroll information by location. Use the checkbox to select the location(s) you want to view on the chart, and click the 'Reset' button to clear the selection.",
                        br(),
                        "Except for the OT hours in the Manhattan borough, the change is not noticeable. The other four boroughs show an upward trend in OT hours from 2015 to 2022"
                      )
               )
             ),
             sidebarLayout(
               sidebarPanel(
                 checkboxGroupInput("location", "Select location(s):",
                                    choices = unique(data$`Work Location Borough`)),
                 br(),
                 actionButton("reset", "Reset")
               ),
               mainPanel(
                 plotlyOutput("ot_plot")
               )
             ),
             fluidRow(
               column(width = 10,
                      offset = 2,
                      p(style = "font-size: 14px; text-align:center;",
                        "Note: The data used in this line chart is based on publicly available information from ",
                        a("New York City's Open Data Portal", href = "https://data.cityofnewyork.us/City-Government/Citywide-Payroll-Data-Fiscal-Year-/k397-673e", target="_blank"),
                        "."
                      )
               )
             )
    ),
    
    tabPanel("Top 20 Agencies with Highest Mean OT Hours",
             fluidRow(
               column(width = 10,
                      offset = 2,
                      titlePanel(HTML("<h1 style='text-align:top center;font-weight:bold;'>What are the Top 20 Agencies that Have the Highest OT Hours?</h1>"))
               )
             ),
             fluidRow(
               column(width = 10,
                      offset = 2,
                      p(style = "font-size: 16px; text-align:top center;font-family: Georgia, serif;",
                        "The figure on the left shows the Top 20 agencies that have the highest OT hours in NYC. We can see that the agency with the most OT hours is the Fire Department. The bar chart on the right shows the perecentage of these 20 agencies in each boroughs. Obviously, the number of police departments is the highest of all boroughs."
                      )
               )
             ),
             wellPanel(
               fluidRow(
                 column(5,
                        plotOutput(outputId = 'flipbarPlot1')
                 ),
                 column(7,
                        plotOutput(outputId = 'flipbarPlot2')
                 )
               )
             ),
             br(),
             fluidRow(
               column(width = 10,
                      offset = 2,
                      p(style = "font-size: 14px; text-align:center;",
                        "Note: The data used in these bar charts is based on publicly available information from ",
                        a("New York City's Open Data Portal", href = "https://data.cityofnewyork.us/City-Government/Citywide-Payroll-Data-Fiscal-Year-/k397-673e", target="_blank"),
                        "."
                      )
               )
             )
    ),
    tabPanel("Network Vis Between Agencies and Boroughs",
             fluidRow(
               column(width = 10,
                      offset = 2,
                      titlePanel(HTML("<h1 style='text-align:top center;font-weight:bold;'>Are the Top 20 Agencies with the Highest Mean OT Hours Present in All Boroughs?</h1>"))
               )
             ),
             fluidRow(
               column(width = 10,
                      offset = 2,
                      p(style = "font-size: 16px; text-align:top center;font-family: Georgia, serif;",
                        "This is the Network Visualization Graph where you can drag the dot and view if the agency is linked to the boroughs.",
                        br(),
                        "No, not every 20 agency is linked to all the boroughs."
                      )
               )
             ),
               mainPanel(
                 visNetworkOutput("network"),
                 br(),
                 htmlOutput("info")
               ),
             fluidRow(
               column(width = 10,
                      offset = 2,
                      p(style = "font-size: 14px; text-align:center;",
                        "Note: The data used in this network graph is based on publicly available information from ",
                        a("New York City's Open Data Portal", href = "https://data.cityofnewyork.us/City-Government/Citywide-Payroll-Data-Fiscal-Year-/k397-673e", target="_blank"),
                        "."
                      )
               )
             )
    )
)


