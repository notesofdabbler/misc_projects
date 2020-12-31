#
#   Explore Binaca Geetmala songs. 
#   The data was extracted from the website:
#   https://www.keepaliveusa.com/binacageetmala/year/1953 where they have nicely
#   compiled songs from 1953 to 1993
#

library(dplyr)
library(tidyr)
library(purrr)
library(ggplot2)

# load songs data
dfr_songs = readRDS(file = "data/songs_all.rds")
df_songs = dfr_songs
df_songs = df_songs %>% mutate(decade = floor(year / 10) * 10)

# check number of songs by year
df_songs %>% count(year) %>% 
   ggplot() + geom_line(aes(x = year, y = n)) + theme_bw()

# keep top n songs from each year
df_songs = df_songs %>% filter(rank <= 1)

# top music directors
df_musicdirs = df_songs %>% mutate(musicdir = map(musicdir, ~paste(.x, collapse = "; "))) 
df_musicdirs_cnt = df_musicdirs %>% count(musicdir, sort = TRUE)
df_musicdirs_dec_cnt = df_musicdirs %>% count(decade, musicdir) %>% arrange(decade, desc(n))

# top singers
df_singers = df_songs %>% select(decade, year, rank, song_name, singers) %>% unnest(singers) 
df_singers_cnt = df_singers %>% count(singers, sort = TRUE)
df_singers_dec_cnt = df_singers %>% count(decade, singers) %>% arrange(decade, desc(n))

tmpqc = df_songs %>% filter(grepl("Ila", singers))

# top actors
df_actors = df_songs %>% select(year, rank, song_name, actors) %>% unnest(actors) 
df_actors_cnt = df_actors %>% count(actors, sort = TRUE)

df_actors %>% filter(grepl("Jaffrey", actors))
