
library(tidytext)
library(dplyr)
library(lubridate)
library(tidyr)
library(topicmodels)
library(ggplot2)

df = read.csv("data/rev_info_bosch_dw_SHEM63W55N.csv", stringsAsFactors = FALSE)

df = df %>% mutate(revid = seq(1, nrow(df)))

df = df %>% mutate(rating2 = rating / 100 * 5)

df %>% count(rating, rating2)

df = df %>% mutate(revdate2 = as_date(revdate, format = "%B %d, %Y"))
df = df %>% mutate(revmnth = floor_date(revdate2), revyr = year(revdate2))

df %>% filter(revyr >= 2019) %>% count(revyr, rating2) %>% 
       group_by(revyr) %>% mutate(n_pct = n / sum(n) * 100) %>% select(-n) %>%
       pivot_wider(names_from = revyr, values_from = n_pct)

df2 = df %>% select(revid, rating2, txt) %>% unnest_tokens(word, txt)

data(stop_words)
df2 = df2 %>% anti_join(stop_words)

xtra_stop_words = c("dishwasher", "review", "promotion", "bosch", "collected")
df2 = df2 %>% filter(!(word %in% xtra_stop_words))

df2 %>% filter(rating2 == 1) %>% count(word, sort = TRUE) %>% head(50)

df2_leak = df2 %>% filter(grepl("leak", word)) %>% distinct(revid) 
df2_leak = inner_join(df, df2_leak, by = "revid") %>% select(txt, rating2)
df2_leak %>% count(rating2)
qc_chk = df2_leak %>% filter(rating2 == 2)

dtm = df2 %>% count(revid, word) %>% cast_dtm(revid, word, n)

rev_lda <- LDA(dtm, k = 10, control = list(seed = 1234))

rev_topics <- tidy(rev_lda, matrix = "beta")

rev_top_terms <- rev_topics %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

rev_top_terms %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(beta, term, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  scale_y_reordered()

rev_documents <- tidy(rev_lda, matrix = "gamma")
rev_documents = rev_documents %>% group_by(document) %>% filter(gamma == max(gamma)) %>% ungroup()
rev_documents = inner_join(rev_documents %>% mutate(revid = as.numeric(document)),
                           df %>% select(revid, rating2), by = "revid")
rev_documents %>% count(topic)

rev_documents %>% count(topic, rating2) %>% group_by(rating2) %>%
         mutate(n_pct = n/sum(n)) %>% select(-n) %>%
         pivot_wider(names_from = rating2, values_from = n_pct) %>% print(width = Inf)
