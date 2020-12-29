
# scrape list of trains and their information for trains in indian railways
# this information is from cleartrip site and used just for hobby to explore
# trains in Indian railways

library(rvest)
library(purrr)
library(dplyr)

url_list = c("https://www.cleartrip.com/trains/amp/list",
             paste0("https://www.cleartrip.com/trains/amp/list?page=",seq(2,5)))
url_list

df_L = list()

for(i in 1:length(url_list)) {
    print(i)
  
    url_html = read_html(url_list[i])
    Sys.sleep(5)
    url_tbl = url_html %>% html_table()
    df_L[[i]] = url_tbl[[1]]
  
}

df = bind_rows(df_L)
names(df) = c("train_no", "train_name", "start", "end")
write.csv(df, "traininfo_ct.csv", row.names = FALSE)
