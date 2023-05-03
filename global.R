library(shiny)
library(rgdal)
library(dplyr)
library(readr)
library(ggplot2)
library(plotly)
library(leaflet)
library(visNetwork)
library(shinythemes)
library(htmltools)
library(RColorBrewer)
library(igraph)

data <- read_csv("Citywide_Payroll_Data__Fiscal_Year_.csv")

data <- data %>%
  filter(`Work Location Borough` %in% c("BROOKLYN", "BRONX", "MANHATTAN", "QUEENS", "RICHMOND"))
data$`Work Location Borough`[data$`Work Location Borough` == "RICHMOND"] <- "Staten Island"
data$`Work Location Borough`[data$`Work Location Borough` == "BRONX"] <- "Bronx"
data$`Work Location Borough`[data$`Work Location Borough` == "BROOKLYN"] <- "Brooklyn"
data$`Work Location Borough`[data$`Work Location Borough` == "QUEENS"] <- "Queens"
data$`Work Location Borough`[data$`Work Location Borough` == "MANHATTAN"] <- "Manhattan"

map_data <- data %>% 
  mutate(total_paid = `Regular Gross Paid` + `Total OT Paid` + `Total Other Pay`) %>%
  group_by(`Work Location Borough`, `Fiscal Year`) %>% 
  summarize(mean_total_paid = mean(total_paid, na.rm = TRUE))

line_data <- data %>%
  group_by(`Work Location Borough`, `Fiscal Year`) %>% 
  summarize(mean_OT_Hours = mean(`OT Hours`, na.rm = TRUE))

# Group data by Agency Name and calculate mean OT Hours
agency_data <- data %>% 
  group_by(`Agency Name`) %>% 
  summarize(mean_OT_Hours = mean(`OT Hours`)) %>% 
  arrange(desc(mean_OT_Hours)) %>% 
  head(20)
# Data that contains only top 20 highest mean OT Hours agency names
top_20_data <- data %>% 
  filter(`Agency Name` %in% agency_data$`Agency Name`)



ny_borough <- rgdal::readOGR("borough_boundaries.geojson")

