library("dplyr")
library("readr")
library("ggplot2")
library("lubridate")
library("knitr")
library("ggthemes")
library("jsonlite")

# import the data on relationship b/w dengue and age
# Prevelance of Dengue Fever in Punjab 2011-12 (http://www.thejaps.org.pk/docs/Supplementary/v-25-sup-2/09.pdf)
## Note that the data was converted from pdf into csv format
dengue_age <- read_csv("Data/age_and_dengue_fever.csv") 
dengue_age

# convert it into a json
dengue_age_json <- toJSON(dengue_age)
write(dengue_age_json, "dengue_age.json")




