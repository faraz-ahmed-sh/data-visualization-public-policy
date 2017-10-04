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
dim(acc2014)

dim(acc2015)

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
count(acc, RUR_URB) # 30,056 NA values exist because acc2014 dataset doesn't have this variable.
# hence combining both datasets will create NA values for the acc2014 dataset

