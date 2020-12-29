
# scrape list of trains and their information for trains in indian railways
# this information is from make my trip site and used just for hobby to explore
# trains in Indian railways

library(rvest)
library(purrr)
library(dplyr)


get_traininfo_pg = function(url_html) {
  
    train_list = url_html %>% html_nodes(".railSeoWrap__trainIndexSingleInfo")
    train_link = map_chr(train_list, function(x) x %>% html_nodes("a") %>% html_attr("href"))
    train_name = map_chr(train_list, function(x) x %>% html_text())
  
    train_df = tibble(train_name, train_link)
  
    return(train_df)
}

get_traininfo = function(url) {

    url_html <- read_html(url)
    Sys.sleep(5)
    
    url_html_L = list()
    url_html_L[[1]] = url_html
    
    url_pg = url_html %>% html_nodes(".railSeoWrap__trainIndexSinglePaginationPage a") %>% html_attr("href")
    
    if(length(url_pg) == 0) {
        return(url_html_L)
    }
    
    url_pg = unique(url_pg)
    url_pg = paste0("https://www.makemytrip.com", url_pg)
    
    for(i in 1:length(url_pg)) {
        url_html_L[[i + 1]] <- read_html(url_pg[i])
        Sys.sleep(5)
    }
    
    return(url_html_L)

}

url_list = paste0("https://www.makemytrip.com/railways/list-of-indian-railway-trains-by-", 
                  letters, ".html")

url_html_L = list()
for(i in 1:length(url_list)) {
    print(i)
    url_html_L[[i]] = get_traininfo(url_list[i])
}

url_html2_L = do.call(c, url_html_L)

traininfo_L = map(url_html2_L, function(x) get_traininfo_pg(x))
traininfo_df = bind_rows(traininfo_L)

write.csv(traininfo_df, "traininfo.csv", row.names = FALSE)
