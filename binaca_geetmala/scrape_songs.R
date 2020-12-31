#
#  This data extracts the list of Binaca Geetmala songs that has been nicely
#  compiled in the site: 
#    https://keepaliveusa.com/
#  into a dataframe to enable exploring the data
#
#

library(rvest)
library(dplyr)
library(purrr)


get_song_yr = function(yr, url) {
  
  url_html = read_html(url)
  
  url_songs = url_html %>% html_nodes(".song-list")
  url_songs = url_songs[2:length(url_songs)]
  url_rank = url_songs %>% html_nodes(".rank.clum") %>% html_text()
  url_song_name = url_songs %>% html_nodes(".song-name") %>% html_text()
  url_singers = map(url_songs %>% html_nodes(".singers.clum"), 
                    function(x) x %>% html_nodes("a") %>% html_text())
  url_musicdir = map(url_songs %>% html_nodes(".music-director.clum"), 
                     function(x) x %>% html_nodes("a") %>% html_text())
  url_lyricist = map(url_songs %>% html_nodes(".lyricist.clum"), 
                     function(x) x %>% html_nodes("a") %>% html_text())
  url_movie = url_songs %>% html_nodes(".movie-album.clum") %>% html_text()
  url_actors = map(url_songs %>% html_nodes(".actors.clum"), 
                   function(x) x %>% html_nodes("a") %>% html_text())
  
  df_yr = tibble(year = yr,
                 rank = as.numeric(url_rank),
                 song_name = url_song_name,
                 singers = url_singers,
                 musicdir = url_musicdir,
                 lyricist = url_lyricist,
                 movie = url_movie,
                 actors = url_actors)

  return(df_yr)  
}

yrlist = seq(1953, 1993)
urllist = paste0("https://www.keepaliveusa.com/binacageetmala/year/", yrlist)

df_yr_L = list()
for(i in 1:length(yrlist)) {
    print(paste0(i, yrlist[i], sep = " "))
    df_yr_L[[i]] = get_song_yr(yrlist[i], urllist[i])
    Sys.sleep(10)
}

df_songs_all = bind_rows(df_yr_L)
saveRDS(df_songs_all, "data/songs_all.rds")
