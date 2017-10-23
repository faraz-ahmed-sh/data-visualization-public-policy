library("dplyr")
library("readr")
library("ggplot2")
library("lubridate")
library("knitr")
library("xtable")
library("ggthemes")
library("tidyverse")
library("treemapify")

# reading the data

FIR_crime_data <- read_csv("Full_FIR_Details_2008to2015.csv")
FIR_crime_data$`Crime Type` <- ifelse(FIR_crime_data$`Crime Type` == "bulgery", "burglary", FIR_crime_data$`Crime Type`)

# rename a variable name
colnames(FIR_crime_data)[1] <- "Neighborhood"

# filter the data for only 2014
FIR_crime_data$year <- substring(FIR_crime_data$Date,7,10)
new <- FIR_crime_data %>% filter(year=="14") 

# Common themes for axes
t_title <- theme(plot.title = element_text(family="Palatino", face="bold", size=20, hjust=0, margin = margin(0, 22, 0, 0)))
t_subtitle <- theme(plot.subtitle=element_text(size=12, family="Georgia", hjust=0, face="italic", color="#8E8883", margin = margin(10, 22, 22, 0)))
t_axis <- theme(axis.title = element_text(family = "Franklin Gothic Book",size=12, color="#635F5D", margin = margin(22, 0, 22, 0)))
axis_labels <- theme(axis.text=element_text(size=10))
t_caption <- theme(plot.caption=element_text(family = "Georgia", hjust = 0, size=8, face="italic", color="black"))
panel_background <- theme(panel.background = element_rect(fill = '#bdbdbd'))
color_plot <- theme(plot.background = element_rect(fill = '#E5E2E0'))

theme_fancy <- theme(plot.title = element_text(family="Palatino", face="bold", size=18, hjust=0, margin = margin(0, 22, 0, 0)),
                       plot.subtitle=element_text(size=13, family="Georgia", hjust=0, face="italic", color="#8E8883", margin = margin(10, 22, 22, 0)),
                       axis.title = element_text(family = "Franklin Gothic Book",size=12, color="#000000", margin = margin(22, 0, 22, 0)),
                       axis.text=element_text(size=10),
                       plot.caption=element_text(family = "Georgia", hjust = 0, size=9, face="italic", color="black"),
                       panel.grid.major.x = element_blank(),
                       panel.grid.minor.x = element_blank(),
                       panel.grid.major.y = element_line( size=.3, color="white" ),
                       panel.grid.minor.y = element_blank(),
                       plot.background = element_rect(fill = '#fce39e'),
                       panel.background = element_rect(fill = '#fce39e'),
                       legend.title = element_text(colour="black", size=10, face="bold"),
                       legend.background = element_rect(fill="#fce39e")
)

theme_simple <- theme(plot.title = element_text(family="Palatino", face="bold", size=18, hjust=0, margin = margin(0, 22, 0, 0)),
                       plot.subtitle=element_text(size=13, family="Georgia", hjust=0, face="italic", color="#8E8883", margin = margin(10, 22, 22, 0)),
                       axis.title = element_text(family = "Franklin Gothic Book",size=12, color="#000000", margin = margin(22, 0, 22, 0)),
                       axis.text=element_text(size=10),
                       plot.caption=element_text(family = "Georgia", hjust = 0, size=9, face="italic", color="black"),
                      panel.border = element_rect(linetype = "solid")
                       )

theme_simple_no_border <- theme(plot.title = element_text(family="Palatino", face="bold", size=18, hjust=0, margin = margin(0, 22, 0, 0)),
                      plot.subtitle=element_text(size=13, family="Georgia", hjust=0, face="italic", color="#8E8883", margin = margin(10, 22, 22, 0)),
                      axis.title = element_text(family = "Franklin Gothic Book",size=12, color="#000000", margin = margin(22, 0, 22, 0)),
                      axis.text=element_text(size=10),
                      plot.caption=element_text(family = "Georgia", hjust = 0, size=9, face="italic", color="black")
)


# summary stats for each year
#------TABLE-------#
by_neighborhood_only <- group_by(new, Neighborhood)
summ_crimes_by_neighborhood_only <-  summarise(by_neighborhood_only, freq = n()) %>%
  arrange(desc(freq))
summ_crimes_by_neighborhood_only


#Graph 1: Bar Chart
by_neighborhood <- group_by(new, Neighborhood, `Crime Type`)
summ_crimes_by_neighborhood_and_type <- summarise(by_neighborhood, freq = n())
summ_crimes_by_neighborhood_and_type

ggplot(data=summ_crimes_by_neighborhood_and_type, aes(x = Neighborhood, y= freq)) + 
  geom_bar(stat="identity", width=0.6, fill="tomato2") +
  theme(aspect.ratio = .6) +
  scale_y_continuous(breaks = (seq(0, 15000, by = 2500))) +
  labs(title = "South of Lahore is the most dangerous part of the city", x = "Neighborhood", y = "Number of Crime Incidences", subtitle="Highest number of crime occurrences took place in the Southeast part of Lahore in 2014.", caption = "Source: Punjab Police Department") +
  theme_current +
  theme(axis.text.x = element_text(angle=65, vjust=0.6))

# Graph 2: plot the number of crimes by neighborhoods and crime type

# find out the top 15 crime types
by_crime_type <- group_by(new, `Crime Type`) %>% summarise(freq = n())
desc_crimetype <- arrange(by_crime_type, desc(freq))[1:15, ]

# filter only those top 15 crime types (remove misc and "other crimes")
crime_type_final <- filter(new, `Crime Type` %in% desc_crimetype$`Crime Type` & (`Crime Type` != "othercrimes") & (`Crime Type` != "miscellaneous"))
final_by_neighborhood <- group_by(crime_type_final, Neighborhood, `Crime Type`) %>%  summarise(freq = n())

ggplot(data=final_by_neighborhood, aes(x = Neighborhood, y = `Crime Type`, size = freq, color=freq)) + 
  geom_point() +
  labs(title = "Top 15 common types of crime in Lahore", x = "Neighborhood", y = "Type of crime", subtitle="Number of crime incidences of various crime types in \ndifferent neighborhoods in 2014.", caption = "Source: Punjab Police Department") +
  guides(color=guide_legend(title="Number of \nCrime Incidences"), size=guide_legend(title="Number of \nCrime Incidences")) +
  theme_simple_no_border + 
  theme(aspect.ratio = 1.0) + 
  theme(panel.background = element_rect(fill = '#E8D85F')) +
  theme(axis.text.x = element_text(angle=90, vjust=0.6))

# Graph 3: heatmap

new$Date <- dmy(new$Date)
new$Month <- month(new$Date, label = TRUE)
new$week_day <- wday(new$Date, label = TRUE)

# Fix the time to hours (round off to the nearest hour)
new$hour <- hour(new$Time)

# summarise the count of crimes according to wday and time
by_wday_crime_count <- new %>% group_by(Month, hour) %>% summarise(freq = n())
k <- "00"
by_wday_crime_count$hour <- paste(by_wday_crime_count$hour, k, sep =":")

ggplot(by_wday_crime_count, aes(x = hour, y = Month, fill = freq)) + 
  geom_tile() +
  scale_x_discrete(limits = c("0:00", "1:00", "2:00", "3:00", "4:00", "5:00", "6:00", "7:00", "8:00", "9:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00")) +
  scale_fill_gradient(low="#FFFB3F", high="#BA3833", limits=c(0, 600)) +
  labs(title = "Crime distribution across different months is evenly spread", x = "Hour of the day", y = "Month", subtitle="Crime rate was consistent across different months in 2014, \nbut most incidences took place between noon and midnight.", caption = "Source: Punjab Police Department") + 
  theme_simple + 
  theme(axis.text.x=element_text(size=7)) +
  guides(fill=guide_legend(title="Number of \nCrime Incidences")) +
  theme(aspect.ratio = 0.7) + 
  theme(panel.border = element_rect(linetype = "blank"))


# Graph 4: Treemap
#First let's codify the type of crime into a proper category as defined in: https://punjabpolice.gov.pk/crimestatistics

crime_type_list <- list(desc_crimetype$`Crime Type`)

new <- new %>% mutate(Crime_type_category = ifelse(`Crime Type` %in% crime_type_list, "", NA))

#create a tibble with crime types and their crime categories
crime_categories <- 
  tribble(
    ~`Crime Type`, ~Crime_Category,
    "miscellaneous", "Miscellaneous",
    "othercrimes", "Other Crimes",
    "motorcycletheft", "Crimes Against Property",
    "robbery", "Crimes Against Property",
    "armsordinanceact", "Other Crimes",
    "narcotics", "Other Crimes",
    "burglary", "Crimes Against Property",
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

# left join on both tables
new_merge <- left_join(new, crime_categories, by = c("Crime Type" = "Crime Type"))

by_crime_cat_crime_count <- new_merge %>% group_by(Crime_Category, `Crime Type`) %>% summarise(freq = n())

ggplot(by_crime_cat_crime_count, aes(area = freq, fill = Crime_Category, label = `Crime Type`, subgroup = Crime_Category)) + 
  geom_treemap() + 
  geom_treemap_text(colour = "white", place = "centre", grow = TRUE) + 
  scale_fill_brewer(palette = "Dark2") + 
  labs(title = "Crimes committed against property exceed the crimes committed against person", subtitle="''Other Crimes'' which includes narcotics and overspeeding, was the major category of crimes committed in 2014.", caption = "Source: Punjab Police Department", fill = "Crime Category") +
  theme(aspect.ratio = 0.7) + theme_simple_no_border
  
  
# Graph 5:

by_month_crime_type_cat <- group_by(new_merge, Crime_Category, Month)  %>% summarise(freq = n())
by_month_crime_type_cat

by_month_crime_type_cat$Month <- as.Date(by_month_crime_type_cat$Month)

ggplot(by_month_crime_type_cat, aes(Month, freq, group = Crime_Category, color = Crime_Category)) + 
  geom_line(size = 1) + geom_point(size = 2) +
  labs(title="Crimes against person decrease throughout the year", 
       subtitle="Miscellaneous Crimes and Other Crimes follow the same pattern, \nespecially in the second half of 2014.", 
       caption="Source: Punjab Police Department", 
       y="Number of Crime Incidences",
       colour = "Crime Category") +
    theme(aspect.ratio = 1.0) +
    theme_fancy
  

# Graph 6: Time-series calendar heatmap

# on data from 2010 to 2014
new_all_data <- FIR_crime_data %>% filter(year %in% c("10", "11", "12", "13", "14"))
new_all_data$Date <- dmy(new_all_data$Date)
new_all_data$Month <- month(new_all_data$Date, label = TRUE)
new_all_data$day <- day(new_all_data$Date)
new_all_data$monthweek <- ceiling(new_all_data$day/ 7)
new_all_data$year <- year(new_all_data$Date)
new_all_data$week_day <- wday(new_all_data$Date, label = TRUE)
new_all_data

# groupby
new_all_data_crime_count <- new_all_data %>% group_by(year, Month, monthweek, week_day) %>% dplyr::summarise(freq_ = n())

ggplot(new_all_data_crime_count, aes(x=monthweek, y=week_day, fill = freq_)) + 
  geom_tile(colour = "white") + 
  facet_grid(year ~ Month) + 
  scale_fill_gradient(low="#BA861A", high="#FF463B", limits=c(0, 300)) +
  labs(x="Week of Month",
       y="Day of the Week",
       title = "Crime rate of Lahore has increased by 600 times since 2010", 
       subtitle="Urbanization, migration and presence of militant groups have significantly contributed \nto the spike in the crime rate of Lahore.",
       caption = "Source: Punjab Police Department",
       fill="Number of \nCrime Incidences") +
  theme_simple_no_border +
  theme(aspect.ratio = 1.4)


# Graph 7: Diverging bars (crime rate type above or below the average)

#First find the average of all the crimes for the year 2014

count_all_crime_types <- new %>% group_by(`Crime Type`) %>% dplyr::summarise(freq_ = n()) 
count_all_crime_types$freq_z <- round((count_all_crime_types$freq_ - mean(count_all_crime_types$freq_))/sd(count_all_crime_types$freq_), 2)

# top 25 crimes
count_all_crime_types <- arrange(count_all_crime_types, desc(freq_))[1:25, ]

count_all_crime_types$crime_type_status <- ifelse(count_all_crime_types$freq_z < 0, "below", "above")  # above / below avg flag
count_all_crime_types <- count_all_crime_types[order(count_all_crime_types$freq_z), ] 
count_all_crime_types$`Crime Type` <- factor(count_all_crime_types$`Crime Type`, levels = count_all_crime_types$`Crime Type`)

ggplot(data = count_all_crime_types, aes(x=`Crime Type`, y=freq_z, label=freq_z)) + 
  geom_bar(stat='identity', aes(fill=crime_type_status), width=.5)  +
  scale_fill_manual(name="Total Number of \nCrime Incidences", 
                    labels = c("Above Average", "Below Average"), 
                    values = c("above"="#00ba38", "below"="#f8766d")) + 
  labs(x="Crime Type",
       y="Deviation from zero",
       title = "Only 25% of all crime types are the most significant",
       subtitle="Most crime types below the average number of crime incidences have the same frequency where as \ncrime types above average have a large difference in crime frequency between each other.",
       caption = "Source: Punjab Police Department",
       fill="Number of \nCrime Incidences") +
  coord_flip() + theme_fancy 

