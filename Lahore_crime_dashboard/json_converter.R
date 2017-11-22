library("dplyr")
library("readr")
library("ggplot2")
library("lubridate")
library("knitr")
library("ggthemes")
library("jsonlite")

# import the data of crime rate of Lahore
FIR_crime_data <- read_csv("Full_FIR_Details_2008to2015.csv")
FIR_crime_data$`Crime Type` <- ifelse(FIR_crime_data$`Crime Type` == "bulgery", "burglary", FIR_crime_data$`Crime Type`)

# rename a variable name
colnames(FIR_crime_data)[1] <- "Neighborhood"
# FIR_crime_data$Time
# filter the data for only 2014 and remove "misc." and "other crimes" crime types
FIR_crime_data$year <- substring(FIR_crime_data$Date,7,10)
lahore_crime_14 <- FIR_crime_data %>% filter((year=="14") & (`Crime Type` != "othercrimes") & (`Crime Type` != "miscellaneous")) 

##Analysis 1: Hour of the day vs. different neighborhoods
lahore_crime_14$Date <- dmy(lahore_crime_14$Date)
lahore_crime_14$Month <- month(lahore_crime_14$Date, label = TRUE)
lahore_crime_14$hour <- hour(lahore_crime_14$Time)
lahore_crime_14$`Crime Type`

lahore_crime_14$Date
class(lahore_crime_14$Time)

datetime <- as.POSIXct(paste(lahore_crime_14$Date, lahore_crime_14$Time, format="%Y-%m-%d %H:%M:%S"))
datetime
lahore_crime_14$datetime <- strptime(datetime)
lahore_crime_14$datetime
# convert it into a json
lahore_crime_14_json <- toJSON(lahore_crime_14, force=TRUE)
write(lahore_crime_14_json, "lahore_crime_14.json")




