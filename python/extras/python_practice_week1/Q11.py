import sys
import urllib.request     # for url response
import re                 # for removing of tags

if len(sys.argv)!=2:
    print("use python filename url")
    sys.exit()
url=sys.argv[1]
response = urllib.request.urlopen(url)
html=response.read()
decoded = html.decode("utf-8")
text=re.sub(r"<.*?>","",decoded)
print(text)