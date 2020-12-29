# scrape list of trains in Indian Railways their station stops
# this information is from cleartrip site and used just for hobby to explore
# trains in Indian railways
#
# Get info on details of each train

library(rvest)
library(purrr)
library(dplyr)
library(stringr)

# read list of trains
df_trains = read.csv("traininfo_ct.csv", stringsAsFactors = FALSE)

# filter to trains whose numbers start with 1, 2, or 5
df = df_trains %>% arrange(train_no) %>% mutate(train_no_chr = str_pad(train_no, 5, pad = "0"))
df = df %>% mutate(d1 = substr(train_no_chr, 1, 1))
df = df %>% filter(d1 %in% c("1", "2", "5"))

# get the page with station stops for each train
sorted_list = sort(df$train_no)
url_list = paste0("https://www.cleartrip.com/trains/amp/", sorted_list)

for(i in 1:length(url_list)) {
    print(i)
    url_html = tryCatch(
      read_html(url_list[i]), 
      error = function(e){NA}    
    )
    if(!is.na(url_html)) {
        write_html(url_html, paste0("tmp/pg_", sorted_list[i], ".html"))
    }
    Sys.sleep(5)
}

# get the list of station stops for each train
get_train_route = function(url_html) {
    train_tt = url_html %>% html_table()
    train_tt_1_df = train_tt[[1]]
    train_tt_1_df = train_tt_1_df %>% mutate(`Stop time` = as.character(`Stop time`),
                                             `Distance travelled` = as.character(`Distance travelled`))
    return(train_tt_1_df)
}

# get train info (duration etc.)
get_train_info = function(url_html) {

    train_info = url_html %>% html_nodes(".tranis-info span") %>% html_text()
    train_name = url_html %>% html_nodes(".col-sm-12 h1") %>% html_text()
    train_name = str_replace_all(train_name, "[\t\n]", "")
    name_split1 = str_split(train_name, "\\(")[[1]][1]
    name_split2 = str_split(name_split1, "-")[[1]]
    info_split = str_split(train_info, ":")
    nstops = as.numeric(info_split[[1]][2])
    duration_hrs = as.numeric(str_split(info_split[[2]][2], " ")[[1]][1])    
    duration_min = as.numeric(str_split(info_split[[2]][2], " ")[[1]][3])    
    duration_tothrs = duration_hrs + duration_min / 60
    type = info_split[[3]][2]
  
    train_info_1_df = tibble(train_no = name_split2[2], train_name = name_split2[1],
                           stops = nstops, duration_hrs = duration_tothrs,
                           type = type)
  
    return(train_info_1_df)
}

# compile train station stops into a dataframe and train info into another dataframe
train_files = list.files("tmp")

train_tt_L = list()
train_info_L = list()

for(i in 1:length(train_files)) {
  
    print(i)
    train_file = paste0("tmp/", train_files[i])
    url_html = read_html(train_file)
    train_tt_L[[i]] = get_train_route(url_html)
    train_info_L[[i]] = get_train_info(url_html)
    train_tt_L[[i]]$train_no = train_info_L[[i]]$train_no
  
}

train_tt_df = bind_rows(train_tt_L)
train_info_df = bind_rows(train_info_L)

write.csv(train_tt_df, "datasets_loc/train_tt_ct.csv", row.names = FALSE)
write.csv(train_info_df, "datasets_loc/train_info_duration_ct.csv", row.names = FALSE)
