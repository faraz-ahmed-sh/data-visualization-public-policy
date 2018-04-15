library("dplyr")
library("readr")
library("ggplot2")
library("lubridate")

# reading the data
FIR_2015_data <- read_csv("Data/Full_FIR_Details_2015(1).csv")
FIR_2015_data

class(FIR_2015_data) # a class of tibble
dim(FIR_2015_data) # 2243 rows and 6 columns

# rename a variable name
colnames(FIR_2015_data)[1] <- "Neighborhood"

# Common themes for axes

t_title <- theme(plot.title = element_text(family="Times New Roman", face="bold", size=20, hjust=0.5))
t_axis <- theme(axis.title = element_text(family = "Arial",size=13))
t_subtitle <- theme(plot.subtitle=element_text(size=12, hjust=0.5, face="italic", color="black"))

# Graph 1: plot the count of number of total crimes in different neighborhoods

by_neighborhood <- group_by(FIR_2015_data, Neighborhood, `Crime Type`)
summ_crimes_by_neighborhood <-  summarise(by_neighborhood, freq = n())
summ_crimes_by_neighborhood

ggplot(data=summ_crimes_by_neighborhood, aes(x = Neighborhood, y= freq)) + 
  geom_bar(stat="identity", width=0.6, fill="brown") +
  theme(aspect.ratio = .6) +
  scale_y_continuous(breaks = (seq(0, 500, by = 50))) +
  labs(title = "What Places in Lahore are Most Crime-Prone?", x = "Neighborhood", y = "Crime Rate", subtitle="Crime rate in different neighborhoods in January 2015.") +
  t_title + t_axis + t_subtitle
  

# Graph 2: plot the number of crimes by neighborhoods and crime type

ggplot(data=summ_crimes_by_neighborhood, aes(x = Neighborhood, y = `Crime Type`, size = freq)) + 
  geom_point() +
  labs(title = "Which Crime Takes Place Where?", x = "Neighborhood", y = "Crime Type", subtitle="Rate of different crime types in different neighborhoods of Lahore in January 2015.") +
  t_title + t_axis + t_subtitle


# Graph 3: plot each crime incidence according to its hour

by_time <- group_by(FIR_2015_data, Time) 
summ_times <- summarise(by_time, freq = n())
summ_times

summ_times$Time <- as.POSIXct(summ_times$Time, format="%H%M%S")

ggplot(summ_times, aes(Time, freq)) + geom_point(size=1.5, color="red") + 
  geom_smooth(method = "lm", se = FALSE) +
  theme(aspect.ratio = .6) +
  scale_x_datetime(date_breaks=("2 hour"), date_labels=("%H:%M")) +
  labs(title = "When Are You Most Likely to be Robbed?", x = "Hour of the day", y = "Crime Rate", subtitle="Most crimes in Lahore happened between 2.00pm and 8.00pm in January 2015.") + 
  t_title + t_axis + t_subtitle

ggsave('myplot2.pdf', width = 12, height = 16, device = cairo_pdf, dpi=300)

# Graph 4: heatmap

# change Date type and create a new variable called "Month"
FIR_2015_data$Date <- dmy(FIR_2015_data$Date)
FIR_2015_data$week_day <- wday(FIR_2015_data$Date)

# Fix the time to hours
FIR_2015_data$hour <- hour(FIR_2015_data$Time)



# summarise the count of crimes according to months
by_wday_crime_count <- FIR_2015_data %>% group_by(week_day, Time) %>% summarise(freq = n())
by_wday_crime_count


