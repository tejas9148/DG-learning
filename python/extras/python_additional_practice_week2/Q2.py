# 2 .datetime - working with dates and times 

# Read: The basics of Python's datetime module - datetime.now(), formatting with strftime, and measuring elapsed time with timedelta. 
# Hands-on: Write a short script that prints the current timestamp, times how long a small loop takes to run, and prints the elapsed time.

from datetime import datetime
from zoneinfo import ZoneInfo
#current time
utc_time = datetime.now(ZoneInfo("UTC"))
ist_time = datetime.now(ZoneInfo("Asia/Kolkata"))
print("UTC time :", utc_time.strftime("%Y-%m-%d %H:%M:%S %Z %z"))
print("IST time :", ist_time.strftime("%Y-%m-%d %H:%M:%S %Z %z"))
#start_timer
start = datetime.now(ZoneInfo("UTC"))

#loop
for i in range(100000):
    pass
 #stop timer
end = datetime.now(ZoneInfo("UTC"))
elapsed = end - start
print("elapsed time:",elapsed)