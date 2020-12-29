
library(dplyr)

df = read.csv("traininfo.csv", stringsAsFactors = FALSE)

df = df %>% arrange(train_no)

tmp = df %>% filter(floor(train_no / 100) == 126)
