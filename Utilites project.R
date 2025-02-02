library(sqldf)
library(dplyr)
library(plotly)


# Load the CSV files into data frames
iou_df <- read.csv("iou_zipcodes_2020.csv", stringsAsFactors = FALSE)
nou_df <- read.csv("non_iou_zipcodes_2020.csv", stringsAsFactors = FALSE)

# Check for any rows with incorrect column counts (here I am validating my data, one file had 10 columns and the other 9)
field_counts <- count.fields("iou_zipcodes_2020.csv", sep = ",")
incorrect_lines <- which(field_counts != 9)
head(incorrect_lines, 10)

# Here i am verifying the number of columns in both files
ncol(iou_df)
ncol(nou_df)

#checking to see if res_rate exists (R says it doesn't)
colnames(Utility_df)
str(Utility_df)
summary(Utility_df)
##so res_rate exists.


# Perform the SQL query using sqldf
Utility_df <- sqldf('SELECT * FROM iou_df
    UNION ALL
    SELECT * FROM nou_df', dbname = "utility_db")

# Check the result
head(Utility_df)

# Conducting the analysis
## Here I am interested in finding the average
## electricity rates for commercial, residential, and industrial
## properties at the state level. 
state.avg.rates <- sqldf('SELECT state, AVG(comm_rate) as comm_rate, AVG(ind_rate) as ind_rate, AVG(res_rate) as res_rate  
                          FROM Utility_df 
                          GROUP BY state 
                          ORDER BY state')

state.avg.rates

state.avg.rates$hover <- with(state.avg.rates, paste(state, '<br>', 'Commercial Rate', round(comm_rate, 3), 
                                                     '<br>', 'Industrial Rate', round(ind_rate, 3),
                                                     '<br>', 'Residential Rate', round(res_rate, 3)))
state.border <- list(color = toRGB('white'))

geo <- list(
  scope = 'usa',
  projection = list(type = 'albers usa'),
  showlakes = TRUE,
  lakecolor = toRGB('white')
)

plt <- plot_ly(state.avg.rates, z = round(res_rate,3), text = hover, locations = state, type = 'choropleth',
             locationmode = 'USA-states', colors = 'Blues', marker = list(line = state.border)) %>%
  layout(title = 'Average Electricity Rates by State', geo = geo)
plotly_POST(p, filename = 'Average Electricity Rates by State')

##modifying the plot_ly() to explicitly reference the data frame
colnames(state.avg.rates) <- tolower(colnames(state.avg.rates))

plt <- plot_ly(state.avg.rates, 
               z = round(state.avg.rates$res_rate, 3), 
               text = state.avg.rates$hover, 
               locations = state.avg.rates$state, 
               type = 'choropleth', 
               locationmode = 'USA-states', 
               colors = 'Blues', 
               marker = list(line = state.border)) %>%
  layout(title = 'Average Electricity Rates by State', geo = geo)

plt
