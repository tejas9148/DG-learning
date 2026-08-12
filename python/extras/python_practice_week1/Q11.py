import sys
import urllib.request     # for url response
import re   
import argparse              # for removing of tags

parser = argparse.ArgumentParser( description ="remove html tags")
parser.add_argument("url",help="url of the webpage")
args=parser.parse_args()
url = args.url
response = urllib.request.urlopen(url)
html=response.read()
decoded = html.decode("utf-8")
text=re.sub(r"<.*?>","",decoded)
print(text)