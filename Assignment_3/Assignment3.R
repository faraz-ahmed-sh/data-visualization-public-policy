library("dplyr")
library("readr")
library("ggplot2")
library("lubridate")
library("viridis")
library("extrafont")
library("rmarkdown")
library("ggthemes")

font_import() # import all your fonts
fonts() #get a list of fonts
fonttable()
fonttable()[40:45,] 

# reading the data
FIR_2015_data <- read_csv("Data/Full_FIR_Details_2015(1).csv")
# rename a variable name
colnames(FIR_2015_data)[1] <- "Neighborhood"

# Common themes for axes
t_title <- theme(plot.title = element_text(family="Times New Roman", face="bold", size=20, hjust=0, margin = margin(0, 22, 0, 0)))
t_subtitle <- theme(plot.subtitle=element_text(size=11, family="Georgia", hjust=0, face="italic", color="#8E8883", margin = margin(10, 22, 22, 0)))
t_axis <- theme(axis.title = element_text(family = "Franklin Gothic Book",size=12, color="#635F5D", margin = margin(22, 0, 22, 0)))
axis_labels <- theme(axis.text=element_text(size=10))
t_caption <- theme(plot.caption=element_text(family = "Georgia", hjust = 0, size=8, face="italic", color="black"))
panel_background <- theme(panel.background = element_rect(fill = '#bdbdbd'))
color_plot <- theme(plot.background = element_rect(fill = '#E5E2E0'))


# Graph 1: plot the count of number of total crimes in different neighborhoods
#theme_set(theme_classic())

summ_crimes_by_neighborhood <- group_by(FIR_2015_data, Neighborhood, `Crime Type`) %>% 
  summarise(freq = n())

ggplot(data=summ_crimes_by_neighborhood, aes(x = Neighborhood, y= freq)) + 
  geom_bar(stat="identity", width=0.6, fill="tomato2") +
  theme(aspect.ratio = .6) +
  scale_y_continuous(breaks = (seq(0, 500, by = 50))) +
  labs(title = "What Places in Lahore are Most Crime-Prone?", x = "Neighborhood", y = "Number of Crime Incidences in January 2015", subtitle="Highest number of crime occurrences happened in the Southeast part of Lahore in January 2015.", caption = "Source: Punjab Police Department") +
  theme_economist() + 
  t_title + t_axis + t_subtitle + t_caption +
  theme(axis.text.x = element_text(angle=65, vjust=0.6))

theme_set(theme_bw())

# Graph 2: plot the number of crimes by neighborhoods and crime type

ggplot(data=summ_crimes_by_neighborhood, aes(x = Neighborhood, y = `Crime Type`, size = freq)) + 
  geom_point() +
  labs(title = "Which Crime Takes Place Where?", x = "Neighborhood", y = "Number of Crime Incidences per Neighborhood", subtitle="Crime rate of different crime types in different neighborhoods of Lahore in January 2015.", caption = "Source: Punjab Police Department") +
  t_title + t_axis + t_subtitle + t_caption + panel_background


# Graph 3: plot each crime incidence according to its hour

by_time <- group_by(FIR_2015_data, Time) 
summ_times <- summarise(by_time, freq = n())

summ_times$Time <- as.POSIXct(summ_times$Time, format="%H%M%S")

ggplot(summ_times, aes(Time, freq)) + geom_point(col="tomato2", size=1.5) + 
  geom_smooth(method="loess", span=0.4, se=TRUE, alpha=0.3) +
  theme(aspect.ratio = .6) +
  scale_x_datetime(date_breaks=("2 hour"), date_labels=("%H:%M")) +
  labs(title = "When Are You Most Likely to be Robbed?", x = "Hour of the day", y = "Number of Crime Incidences per minute", subtitle="Most crimes in Lahore happened between 2.00pm and 8.00pm in January 2015.", caption = "Source: Punjab Police Department") + 
  theme_wsj() + t_title + t_axis + t_subtitle + t_caption + axis_labels

#ggsave('myplot2.pdf', width = 12, height = 16, device = cairo_pdf, dpi=300)

# Graph 4: heatmap

# change Date type and create a new variable called "Month"
FIR_2015_data$Date <- dmy(FIR_2015_data$Date)
FIR_2015_data$week_day <- wday(FIR_2015_data$Date, label = TRUE)

# Fix the time to hours
FIR_2015_data$hour <- hour(FIR_2015_data$Time)

# summarise the count of crimes according to wday and time
by_wday_crime_count <- FIR_2015_data %>% group_by(week_day, hour) %>% summarise(freq = n())
k <- "00"
by_wday_crime_count$hour <- paste(by_wday_crime_count$hour, k, sep =":")

ggplot(by_wday_crime_count, aes(x = hour, y = week_day, fill = freq)) + 
  geom_tile() +
  scale_x_discrete(limits = c("0:00", "1:00", "2:00", "3:00", "4:00", "5:00", "6:00", "7:00", "8:00", "9:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00")) +
  scale_fill_gradient(low="#FFFB3F", high="#BA3833", limits=c(0, 80), na.value="transparent") +
  labs(title = "Crime Distribution Across Week Days", x = "Hour of the day", y = "Day of the week", subtitle="Most crimes in Lahore occurred on Thursday, Friday and Saturday during midday and early afternoon in January 2015.", caption = "Source: Punjab Police Department") + 
  t_title + t_axis + t_subtitle + t_caption
  

# Graph 5: facet grid
#theme_set(theme_bw())
by_wday_area_crime_count <- FIR_2015_data %>% group_by(week_day, Neighborhood) %>% summarise(freq = n())

ggplot(by_wday_area_crime_count, aes(x = week_day, y = freq)) + 
  geom_bar(stat="identity", fill = "#7258BA") +
  facet_wrap(~Neighborhood, ncol = 2) + 
  labs(title = "In Lahore, Be Careful on Weekends", x = "Day of the Week", y = "Number of Crime Incidences in January 2015", subtitle="Most neighborhoods of Lahore are crime-prone on Thursday, Friday and Saturday during midday and early afternoon in January 2015.", caption = "Source: Punjab Police Department") + 
  t_title + t_axis + t_subtitle + t_caption +
  theme(aspect.ratio = 0.65) +
  theme(axis.text.x = element_text(angle = 90),
        strip.text = element_text(face = "plain", 
                                  size = rel(0.5)))
