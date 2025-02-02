library(readr)
library(data.table)
library(dplyr)
library(ggplot2)
library(tidyr)

#upload data
##All Usage Expressed in Millions of kWh (GWh) http://www.ecdms.energy.ca.gov/elecbycounty.aspx
##ec is abbreviated for electrical consumption. 
ec <- read_csv("C:/Users/Sherveen/Downloads/R Practice/data/ElectricityByCounty.csv")

#view the structure of the data
str(ec)
summary(ec)

ncol(ec)
nrow(ec)

head(ec)

#begin analysis for the data as a whole by creating visuals. 
##converting columns to numeric and excluding columns with string observations
ec_numeric <- ec %>%
  select(-c(County, Sector, 'Total Usage'))%>%
  summarise_all(mean)

summary(ec_numeric)

#converting data to long format for plotting
ec_long <- ec %>%
  pivot_longer(cols = -c(County, Sector, `Total Usage`), names_to = "Year", values_to = "Usage") %>%
  mutate(Year = as.numeric(Year))

#aggregate total usage by year
ec_yearly <- ec_long %>%
  group_by(Year)%>%
  summarise(Total_Usage = sum(Usage))

#Here is a time series plot displaying electicity usage over time
ggplot(ec_yearly, aes(x = Year, y = Total_Usage))+
  geom_line(color = "blue") +
  geom_point(color = "red") +
  ggtitle("Total Electricity Usage Over Time") +
  xlab("Year") +
  ylab("Electricity Usage (Total)") +
  theme_minimal()

#Exporing Usage by County/Sector
ec_county_usage <- ec_long %>%
  group_by(County) %>%
  summarise(Total_Usage = sum(Usage))

ggplot(ec_county_usage, aes(x = reorder(County, Total_Usage), y = Total_Usage)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  coord_flip() + 
  ggtitle("Total Electricity Usage by County") +
  xlab("County") + 
  ylab("Total Usage (Millions of kWh)")

##Los Angeles has the highest electricity consumption

