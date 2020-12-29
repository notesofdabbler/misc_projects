
library(dplyr)
library(stringr)
library(ggplot2)

dfr_info = read.csv("datasets_loc/traininfo_ct.csv", stringsAsFactors = FALSE)
dfr_info_2 = read.csv("datasets_loc/train_info_duration_ct.csv", stringsAsFactors = FALSE)
dfr_tt = read.csv("datasets_loc/train_tt_ct.csv", stringsAsFactors = FALSE)

# df_info_2 is filtered to trains that start with digits 1, 2, or 5
df_info = inner_join(dfr_info %>% distinct(train_no, .keep_all = TRUE) %>% select(-train_name),
                     dfr_info_2, by = "train_no")

# there was one entry with negative duration which is actually positive
df_info = df_info %>% mutate(duration_hrs = abs(duration_hrs))

# check types of trains in dataset
df_info %>% count(type, sort = TRUE)

# histogram of train duration
ggplot(df_info) + geom_histogram(aes(x = duration_hrs)) + theme_bw()
ggplot(df_info) + stat_ecdf(aes(x = duration_hrs), geom = "step") + theme_bw()

# check longest routes
df_info %>% arrange(desc(duration_hrs)) %>% head(20)

# check stations with largest number of train starts/ends
topstarts = df_info %>% count(start, sort = TRUE)
topends = df_info %>% count(end, sort = TRUE)
head(topstarts, 20)
head(topends, 20)

# check routes that have highest number of trains operating between them
toproutes = df_info %>% group_by(start, end) %>% summarize(cnt = n()) %>% arrange(desc(cnt))
head(toproutes, 20)
toproutes %>% ungroup() %>% count(cnt)

start_station = "Chennai Central"
end_station = "H Nizamuddin"
df2 %>% filter(start == start_station, end == end_station)
