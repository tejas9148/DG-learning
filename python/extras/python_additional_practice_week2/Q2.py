# 2 .datetime - working with dates and times 

# Read: The basics of Python's datetime module - datetime.now(), formatting with strftime, and measuring elapsed time with timedelta. 
# Hands-on: Write a short script that prints the current timestamp, times how long a small loop takes to run, and prints the elapsed time.

from datetime import datetime

#current time
current_time = datetime.now()
print("current time :",current_time.strftime("%Y-%m-%d %H:%M:%S"))

#start_timer
start=datetime.now()

#loop
for i in range(100000):
    pass
 #stop timer
end = datetime.now()
elapsed = end - start
print("elepsed time:",elapsed)