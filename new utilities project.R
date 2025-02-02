library(sqldf)
library(dplyr)
library(plotly)

# Load data
iou_df <- read.csv("iou_zipcodes_2020.csv", stringsAsFactors = FALSE)
nou_df <- read.csv("non_iou_zipcodes_2020.csv", stringsAsFactors = FALSE)

# Ensure res_rate exists and is numeric
iou_df$res_rate <- as.numeric(iou_df$res_rate)
nou_df$res_rate <- as.numeric(nou_df$res_rate)

# Perform SQL UNION ALL
Utility_df <- sqldf('SELECT * FROM iou_df UNION ALL SELECT * FROM nou_df')

# Compute state averages
state.avg.rates <- sqldf('SELECT state, AVG(comm_rate) as comm_rate, 
                                 AVG(ind_rate) as ind_rate, 
                                 AVG(res_rate) as res_rate  
                          FROM Utility_df 
                          GROUP BY state 
                          ORDER BY state')

# Ensure columns are numeric
state.avg.rates$comm_rate <- as.numeric(state.avg.rates$comm_rate)
state.avg.rates$ind_rate <- as.numeric(state.avg.rates$ind_rate)
state.avg.rates$res_rate <- as.numeric(state.avg.rates$res_rate)

# Convert state names to abbreviations
state.avg.rates$state <- state.abb[match(state.avg.rates$state, state.name)]

# Create hover text
state.avg.rates$hover <- with(state.avg.rates, paste(state, '<br>', 
                                                     'Commercial Rate', round(comm_rate, 3), 
                                                     '<br>', 'Industrial Rate', round(ind_rate, 3),
                                                     '<br>', 'Residential Rate', round(res_rate, 3)))

# Define map settings
state.border <- list(color = plotly::toRGB('white'))
geo <- list(scope = 'usa', projection = list(type = 'albers usa'), 
            showlakes = TRUE, lakecolor = plotly::toRGB('white'))

# Generate plot
plt <- plot_ly(state.avg.rates, 
               z = round(state.avg.rates$res_rate, 3), 
               text = state.avg.rates$hover, 
               locations = state.avg.rates$state, 
               type = 'choropleth', 
               locationmode = 'USA-states', 
               colorscale = 'Blues', 
               marker = list(line = state.border)) %>%
  layout(title = 'Average Electricity Rates by State', geo = geo)

plt

#going to check to see if state has the all the proper values
unique(state.avg.rates$state)
print(unique(state.avg.rates$state))  # Check state names before conversion
unique_states <- unique(state.avg.rates$state[!is.na(state.avg.rates$state)])
print(unique_states)
##chekcing the number of non-NA values
sum(!is.na(state.avg.rates$state))

# Remove any leading/trailing spaces
state.avg.rates$state <- trimws(state.avg.rates$state)

# Then try getting unique values again
unique_states <- unique(state.avg.rates$state[!is.na(state.avg.rates$state)])
print(unique_states)

head(state.avg.rates$state)

str(state.avg.rates)

ncol(state.avg.rates)

source("C:/Users/Sherveen/Downloads/R Practice/Utilites project.R")

