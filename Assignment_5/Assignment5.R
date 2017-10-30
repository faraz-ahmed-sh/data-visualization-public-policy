library("dplyr")
library("readr")
library("ggplot2")
library("lubridate")
library("knitr")
library("ggthemes")
library("tidyverse")
library("stringr")
library("rgdal")
library("mapproj")
library("scales")
library(gpclib)
library(sp)
library(rgeos)
library(rgdal)
library(maptools)
library(maps)

theme_simple_no_border <- theme(plot.title = element_text(family="Palatino", face="bold", size=18, hjust=0, margin = margin(0, 22, 0, 0)),
                                plot.subtitle=element_text(size=13, family="Georgia", hjust=0, face="italic", color="#8E8883", margin = margin(10, 22, 22, 0)),
                                axis.title = element_text(family = "Franklin Gothic Book",size=12, color="#000000", margin = margin(22, 0, 22, 0)),
                                axis.text=element_text(size=10),
                                plot.caption=element_text(family = "Georgia", hjust = 0, size=9, face="italic", color="black")
)

theme_map <- theme(axis.ticks = element_blank(),
                   axis.text.x = element_blank(),
                   axis.text.y = element_blank(),
                   axis.title.x=element_blank(),
                   axis.title.y=element_blank(),
                   panel.background = element_blank(),
                   panel.border = element_blank(), 
                   plot.title = element_text(family="Palatino", face="bold", size=18, hjust=0, margin = margin(0, 22, 0, 0)), 
                   plot.subtitle=element_text(size=13, family="Georgia", hjust=0, face="italic", color="#8E8883", margin = margin(10, 22, 22, 0)), 
                   plot.caption=element_text(family = "Georgia", hjust = 0, size=9, face="italic", color="black"),
                   rect = element_blank()
)

# MAP 1:

## read the shapefile with ReadOGR:

chicago_beat_map <- readOGR(dsn="ChicagoPoliceBeats", layer="ChicagoPoliceBeats")

class(chicago_beat_map)
chicago_beat_map@data

chicago_beat.points <- fortify(chicago_beat_map, region="beat_num")

ggplot(data=chicago_beat.points, aes(long, lat, group = group, fill = id)) +
  geom_polygon() +
  geom_path(color="white") +
  theme(legend.position="none") +
  coord_equal()

# read in the dataset on complaints against police officers (by beats) obtained from Invisible Institute website: https://github.com/invinst/chicago-police-data
chicago_police_complaints <- read.csv("complaints.csv")

# filter only the data for year 2016
chicago_police_complaints$Year <- format(as.Date(chicago_police_complaints$incident_datetime),"%Y")
chicago_police_complaints_2016 <- chicago_police_complaints %>% filter(Year == "2016")
dim(chicago_police_complaints_2016)
#1331 incidences

# use string pads to ensure consistency in "beat" codes in both shape files and complaints dataset

chicago_police_complaints_2016$beat <- str_pad(chicago_police_complaints_2016$beat, 4, side="left", pad = 0)

# perform descriptive statistics by beat

count_complaints_per_beat <- chicago_police_complaints_2016 %>% group_by(beat) %>% summarise(freq = n())

# Combine the dataset on complaints against police (by beats) with the beats points
chicago_beat_2016 <- left_join(chicago_beat.points, count_complaints_per_beat, by = c("id" = "beat"))
chicago_beat_2016


ggplot(data=chicago_beat_2016, aes(long, lat, group = group, fill = freq)) +
  geom_polygon() +
  geom_path(color="#E5E4D4") +
  coord_equal(1.2) +
  theme_map + 
  scale_fill_distiller(name = "No. of complaints \nagainst police officers", palette = "Spectral") + 
  labs(title = "Complaints against police highest in Chicago's South Side", subtitle="South Side and Far Southest Side generated highest number of complaints \nagainst police offciers in 2016.", caption = "Source: Invisible Institute and City of Chicago")
  

# MAP 2: 

## read in Pakistan's districts shape file
pakistan_district_map <- readOGR(dsn="pakistan_district", layer="pakistan_district")

class(pakistan_district_map)
pakistan_district_map@data

pak_district.points <- fortify(pakistan_district_map, region="district")
pak_district.points

ggplot(data=pak_district.points, aes(long, lat, group = group)) +
  geom_polygon() +
  geom_path(color="gray") +
  theme(legend.position="none") +
  coord_equal()

## read in data on Pakistan Annual Status of Education Report
## Obtained from: Pakistan Data Portal (http://data.org.pk/frontend/web/masterdatasetdetails/index?dataset_id=433)

pak_educ_status <- read.csv("Annual_status_of_education_report_Pakistan.csv") 

pak_educ_status$District <- as.character(pak_educ_status$District) 

pak_educ_status$District <-  tolower(pak_educ_status$District) 

pak_educ_status <- pak_educ_status %>% filter(Indicators == "Dropouts" & Age == "6-16 years")
pak_educ_status$Value <- (as.numeric(pak_educ_status$Value))/100
pak_educ_status
dim(pak_educ_status)
#330 data points

pak_district_educ.df <- left_join(pak_district.points, pak_educ_status, by = c("id" = "District"))
pak_district_educ.df

ggplot(data=pak_district_educ.df, aes(long, lat, group = group, fill = Value)) +
  geom_polygon() +
  geom_path(color="#E5E4D4") +
  coord_map(1) +
  theme(legend.position="bottom", legend.justification = c(0, 1), legend.text=element_text(size=7)) +
  theme_map + 
  scale_fill_distiller(name = "Dropout percentage", palette = "RdBu", limits = c(0, 0.25), breaks=seq(0,0.25,by=0.05), labels = percent) +
  labs(title = "Complaints against police highest in Chicago's South Side", subtitle="South Side and Far Southest Side generated highest number of complaints \nagainst police offciers in 2016.", caption = "Source: Invisible Institute and City of Chicago")




