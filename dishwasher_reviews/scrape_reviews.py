#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Nov 25 14:06:17 2020

@author: shanki
"""


#
# Youtube help: https://www.youtube.com/channel/UC46vj6mN-6kZm5RYWWqebsg
#

from selenium import webdriver
import requests
from bs4 import BeautifulSoup
import pandas as pd
import time
import re

driver = webdriver.Chrome()
driver.maximize_window()

url_str = "https://www.homedepot.com/p/Bosch-300-Series-Front-Control-Tall-Tub-Dishwasher-in-Stainless-Steel-with-Stainless-Steel-Tub-and-3rd-Rack-44dBA-SHEM63W55N/304644690"

driver.get(url_str)


rev_html2_l = []

N = 250

for i in range(N):
    
    print(i)
    
    rev_html = driver.execute_script("return document.body.innerHTML;")
    rev_html2 = BeautifulSoup(rev_html, 'html.parser')
    
    rev_html2_l.append(rev_html2)
    
    l=driver.find_element_by_xpath("//a[@aria-label='Next']")
    l.click()
    
    time.sleep(2.0)


def rev_info(rev_html2):
    revtitle_html = rev_html2.find_all("span", {"class":"review-content__title"})
    revtitle = [x.text for x in revtitle_html]

    revtxt_html = rev_html2.find_all("div", {"class":"review-content-body"})
    revtxt = [x.text for x in revtxt_html]
    
    revdt_html = rev_html2.find_all("span", {"class":"review-content__date"})
    revdt = [x.text for x in revdt_html]

    revrating_html = rev_html2.find_all("div", {"class":"review-content__col2"})
    revrating = [x.find("span", {"class":"stars"}).get('style') for x in revrating_html]
    revrating_num = [int(re.findall(r'\d+', x)[0]) for x in revrating]
    
    rev_info_df = pd.DataFrame({'title':revtitle, 'txt': revtxt, 'rating': revrating_num, 'revdate': revdt})
    
    return rev_info_df

rev_info_df_l = []

for i, rev_html2 in enumerate(rev_html2_l):
    print(i)
    rev_info_df = rev_info(rev_html2)
    rev_info_df_l.append(rev_info_df)
    
rev_info_all_df = pd.concat(rev_info_df_l)

rev_info_all_df.to_csv('rev_info.csv', index = False)





    




