#5. Write a program anti_html.py that takes a URL as an argument, downloads the HTML from
#the web, and prints it after stripping HTML tags.

import sys
import requests
from bs4 import BeautifulSoup

url = sys.argv[1]

response = requests.get(url)
response.raise_for_status()

soup = BeautifulSoup(response.text, "html.parser")
print(soup.get_text(" ", strip=True))