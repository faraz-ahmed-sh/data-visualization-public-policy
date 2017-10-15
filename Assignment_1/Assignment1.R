library("readr")
library("haven")
library("dplyr")
library("tidyr")
library("stringr")
library("ggplot2")

# reading the data

acc2015 <- read_csv("2015/accident.csv")
acc2015
acc2014 <- read_sas("2014/accident.sas7bdat")
acc2014
ls()

# looking at which class functions() the objects follow

class(acc2014)
class(acc2015)
# the class functions are of 1) class data.frame and 2) class tbl

acc2014$TWAY_ID2

# mutate strings in acc2014$RWAY_ID2 to NA

acc2014 <- mutate(acc2014, TWAY_ID2 = na_if(TWAY_ID2, ""))
table(is.na(acc2014$TWAY_ID2))

# dim
dim(acc2014) # 30,056 rows and 50 columns
dim(acc2015) # 32,166 rows and 52 columns

# identifying columns in one dataset but not in another

col_names_2014 <- colnames(acc2014)
col_names_2015 <- colnames(acc2015)

diff_columns_in_2014 <- col_names_2014[! col_names_2014 %in% col_names_2015]
diff_columns_in_2014
# Column in 2014 but not in 2015 dataset is "ROAD_FNC"

diff_columns_in_2015 <- col_names_2015[! col_names_2015 %in% col_names_2014]
diff_columns_in_2015
#  Columns in 2015 but not in 2014 dataset are "RUR_URB", "FUNC_SYS" and "RD_OWNER"

# Combining two tibbles into one tibble

acc <- bind_rows(acc2014, acc2015)

# frequency table of the variable RUR_URB

count(acc, RUR_URB) 
# 30,056 NA values exist because acc2014 dataset doesn't have this variable.
# hence combining both datasets will create NA values for the acc2014 dataset

# loading the "FIPS" dataset

fips <- read_csv("fips.csv")
glimpse(fips)

acc$STATE <- as.character(acc$STATE)
acc$COUNTY <- as.character(acc$COUNTY)

# Adding string pads to STATE and COUNTY variables of acc tibble

acc$STATE <- str_pad(acc$STATE, 2, side="left", pad = 0)
acc$COUNTY <- str_pad(acc$COUNTY, 3, side="left", pad = 0)

# Rename variables names
acc <- rename(acc, "StateFIPSCode" = "STATE", "CountyFIPSCode" = "COUNTY")
acc

# left join of two tibbles

acc_merge <- left_join(acc, fips, by = c("StateFIPSCode" = "StateFIPSCode", "CountyFIPSCode" =  "CountyFIPSCode"))

# summary of fatalities by state for each of the past two years

by_state_year <- group_by(acc_merge, StateName, YEAR)
agg <- summarise(by_state_year, total_fatalities = (freq = n()))

# spread
agg_wide <- spread(agg, key = YEAR, value = total_fatalities)
agg_wide

# mutate to calculate % differerence
agg_wide_new <- mutate(agg, lag = lag(total_fatalities)) %>% 
  mutate(percent_difference =  ((total_fatalities-lag)/lag)*100)

# arrange
agg_wide_final <- arrange(agg_wide_new, desc(percent_difference))

# filter
agg_wide_final <- filter(agg_wide_final, percent_difference > 15 & !is.na(StateName))
glimpse(agg_wide_final)

# Using chain operator to perform the operations above in a single pass
agg_final <- 
  mutate(agg) %>%
  mutate(lag = lag(total_fatalities)) %>%
  mutate(percent_difference = ((total_fatalities - lag)/lag)*100) %>%
  arrange(desc(percent_difference)) %>%
  filter(percent_difference > 15 & !is.na(StateName))

agg_final
glimpse(agg_final)
