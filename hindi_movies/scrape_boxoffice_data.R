
library(rvest)
library(dplyr)
library(tidyr)
library(purrr)
library(stringr)

# https://muvyz.com/boxoffice/byyear/y6/2010


clean_npages = function(n_pages) {
  x = strsplit(n_pages, "/")[[1]][2]
  x = str_replace_all(x, "(\n|>)", "")
  x = as.numeric(x)
  return(x)
}

clean_rev_inr = function(rev_inr) {
  x = str_replace_all(rev_inr, "(\u20b9|,)", "")
  x = as.numeric(x)
  return(x)
}



get_movie_df = function(url, yr) {
    url_html = read_html(url)
    n_pages = url_html %>% html_node(".pagenum") %>% html_text() %>% clean_npages()
    n = ifelse(is.na(n_pages), 1, n_pages + 1)
    df_L = list()
    for (i in 1:n) {
        titles = url_html %>% html_nodes(".movieimage img") %>% html_attr("title")
        rev_inr = url_html %>% html_nodes(".movieimage .red") %>% html_text() %>%
          map_dbl(function(x) clean_rev_inr(x))
        df_L[[i]] = tibble(year = yr, title = titles, rev_inr = rev_inr)      
    }

    df = bind_rows(df_L)
    return(df)
}

yrlist = seq(1950, 2020)
yrsuffix = c(rep(paste0("y", seq(0, 6)), each = 10), "y6")
url_list = paste0("https://muvyz.com/boxoffice/byyear/", yrsuffix, "/", yrlist, "/")

url = url_list[60]

tmp = get_movie_df(url, 2000)
