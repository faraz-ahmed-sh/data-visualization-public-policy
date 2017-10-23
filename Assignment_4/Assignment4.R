library("dplyr")
library("readr")
library("ggplot2")
library("lubridate")
library("knitr")
library("xtable")
library("ggthemes")
library("tidyverse")
library(devtools)


install.packages("treemapify")
library(treemapify)
# reading the data

FIR_crime_data <- read_csv("Full_FIR_Details_2008to2015.csv")
FIR_crime_data

# rename a variable name
colnames(FIR_crime_data)[1] <- "Neighborhood"

# filter the data for only 2015 
class(FIR_crime_data$Date)
FIR_crime_data$year <- substring(FIR_crime_data$Date,7,10)
new <- FIR_crime_data %>% filter(year=="14") 

# change Date type and create a new variable called "Month"
new$Date <- dmy(new$Date)
new$Month <- month(new$Date, label = TRUE)

# summarise the count of crimes according to months
by_month_crime_count <- new %>% group_by(Month) %>% summarise(freq = n())
by_month_crime_count
kable(by_month_crime_count)

# Common themes for axes
t_title <- theme(plot.title = element_text(family="Times New Roman", face="bold", size=20, hjust=0, margin = margin(0, 22, 0, 0)))
t_subtitle <- theme(plot.subtitle=element_text(size=12, family="Georgia", hjust=0, face="italic", color="#8E8883", margin = margin(10, 22, 22, 0)))
t_axis <- theme(axis.title = element_text(family = "Franklin Gothic Book",size=12, color="#635F5D", margin = margin(22, 0, 22, 0)))
axis_labels <- theme(axis.text=element_text(size=10))
t_caption <- theme(plot.caption=element_text(family = "Georgia", hjust = 0, size=8, face="italic", color="black"))
panel_background <- theme(panel.background = element_rect(fill = '#bdbdbd'))
color_plot <- theme(plot.background = element_rect(fill = '#E5E2E0'))

# summary stats for each year
#------TABLE-------#
by_neighborhood_only <- group_by(new, Neighborhood)
summ_crimes_by_neighborhood_only <-  summarise(by_neighborhood_only, freq = n()) %>%
  arrange(desc(freq))
summ_crimes_by_neighborhood_only


#GRAPH 1 
by_neighborhood <- group_by(new, Neighborhood, `Crime Type`)
summ_crimes_by_neighborhood_and_type <- summarise(by_neighborhood, freq = n())
summ_crimes_by_neighborhood_and_type

ggplot(data=summ_crimes_by_neighborhood_and_type, aes(x = Neighborhood, y= freq)) + 
  geom_bar(stat="identity", width=0.6, fill="tomato2") +
  theme(aspect.ratio = .6) +
  scale_y_continuous(breaks = (seq(0, 15000, by = 2500))) +
  labs(title = "South of Lahore is the most dangerous part of the city", x = "Neighborhood", y = "Number of Crime Incidences", subtitle="Highest number of crime occurrences took place in the Southeast part of Lahore in 2014.", caption = "Source: Punjab Police Department") +
  theme_economist() + 
  t_title + t_axis + t_subtitle + t_caption +
  theme(axis.text.x = element_text(angle=65, vjust=0.6))

# Graph 2: plot the number of crimes by neighborhoods and crime type

# find out the top 10 crime types
by_crime_type <- group_by(new, `Crime Type`) %>% summarise(freq = n())
by_crime_type

desc_crimetype <- arrange(by_crime_type, desc(freq))[1:10, ]
desc_crimetype


# filter only those top 10 crime types
crime_type_final <- filter(new, `Crime Type` %in% desc_crimetype$`Crime Type` & (`Crime Type` != "othercrimes") & (`Crime Type` != "miscellaneous"))
crime_type_final

final_by_neighborhood <- group_by(crime_type_final, Neighborhood, `Crime Type`) %>%  summarise(freq = n())
final_by_neighborhood

ggplot(data=final_by_neighborhood, aes(x = Neighborhood, y = `Crime Type`, size = freq, color=freq)) + 
  geom_point() +
  labs(title = "Top 10 Common types of crime in Lahore", x = "Neighborhood", y = "Type of crime", subtitle="Number of crime incidences of various crime types in different neighborhoods in 2014.", caption = "Source: Punjab Police Department") +
  t_title + t_axis + t_subtitle + t_caption + panel_background + 
  theme(axis.text.x = element_text(angle=90, vjust=0.6)) + guides(color=guide_legend(title="Number of \nCrime Incidences"), size=guide_legend(title="Number of \nCrime Incidences")) 

# Graph 3: heatmap

# change Date type and create a new variable called "Month"
new$week_day <- wday(new$Date, label = TRUE)

# Fix the time to hours
new$hour <- hour(new$Time)

# summarise the count of crimes according to wday and time
by_wday_crime_count <- new %>% group_by(Month, hour) %>% summarise(freq = n())
by_wday_crime_count
k <- "00"
by_wday_crime_count$hour <- paste(by_wday_crime_count$hour, k, sep =":")

ggplot(by_wday_crime_count, aes(x = hour, y = Month, fill = freq)) + 
  geom_tile() +
  scale_x_discrete(limits = c("0:00", "1:00", "2:00", "3:00", "4:00", "5:00", "6:00", "7:00", "8:00", "9:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00")) +
  scale_fill_gradient(low="#FFFB3F", high="#BA3833", limits=c(0, 600)) +
  labs(title = "Crime distribution across different months", x = "Hour of the day", y = "Month", subtitle="Crime rate was almost the same across different months in 2014, \nbut most incidences took place between noon and midnight.", caption = "Source: Punjab Police Department") + 
  t_title + t_axis + t_subtitle + t_caption + theme(axis.text.x=element_text(size=7)) +
  guides(fill=guide_legend(title="Number of \nCrime Incidences"))

# Graph 4:Treemap
#First let's codify the type of crime into a proper category as defined in: https://punjabpolice.gov.pk/crimestatistics

crime_type_list <- list(desc_crimetype$`Crime Type`)

new <- new %>% mutate(Crime_type_category = ifelse(`Crime Type` %in% crime_type_list, "", NA))

crime_categories <- 
  tribble(
    ~`Crime Type`, ~Crime_Category,
    "miscellaneous", "Miscellaneous",
    "othercrimes", "Other Crimes",
    "motorcycletheft", "Crimes Against Property",
    "robbery", "Crimes Against Property",
    "armsordinanceact", "Other Crimes",
    "narcotics", "Other Crimes",
    "bulgery", "Crimes Against Property",
    "antinorcoticsact", "Other Crimes",
    "beggingact", "Crimes Against Person",
    "chequedishonour", "Crimes Against Person",
    "overspeeding", "Other Crimes",
    "cartheft", "Crimes Against Property",
    "gambling", "Crimes Against Person",
    "pricecontrol", "Other Crimes",
    "othervehicletheft", "Crimes Against Property",
    "attemptedmurder", "Crimes Against Person",
    "dengueact", "Other Crimes",
    "kiteflyingact","Other Crimes",
    "kidnapping", "Crimes Against Person", 
    "loudspeakeract", "Other Crimes",
    "telephoneact", "Other Crimes",
    "hurtpersonalfeud", "Crimes Against Person",
    "attackongovtservant", "Crimes Against Person",
    "localgovernment", "Other Crimes",
    "outragingthemodestyofwomen", "Crimes Against Person",
    "electricityact", "Crimes Against Property",
    "murder", "Crimes Against Person",
    "ppc", "Other Crimes",
    "motorcyclesnatching", "Crimes Against Property",
    "onewheeling", "Other Crimes",
    "fatalaccident", "Other Crimes",
    "kidnappingminors", "Crimes Against Person",
    "rape", "Crimes Against Person",
    "tresspassing", "Other Crimes",
    "illegalextortion", "Other Crimes",
    "nonfatalaccident", "Other Crimes",
    "blindmurder", "Crimes Against Person", 
    "gangrape", "Crimes Against Person",
    "policeencounter", "Other Crimes",           
    "hubsebeja", "Other Crimes",
    "dacoity", "Crimes Against Property",             
    "copyrightact", "Other Crimes",
    "antiterrorism", "Other Crimes", 
    "policeorder", "Other Crimes",
    "illegalgascylinder", "Other Crimes",      
    "carsnatching", "Crimes Against Property",
    "dacoitywithmurder", "Crimes Against Property",      
    "secratarianism", "Other Crimes",
    "othervehiclesnatching", "Crimes Against Property",     
    "kidnapforransom", "Crimes Against Person",
    "bordercrossing", "Other Crimes", 
    "cigretteact", "Other Crimes"
  )

new_merge <- left_join(new, crime_categories, by = c("Crime Type" = "Crime Type"))


# Graph 5: Time-series calendar heatmap (~facet wrap)







# Graph 6: Diverging bars (crime rate above or below the average)



