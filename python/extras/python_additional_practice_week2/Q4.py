#  Config files - configparser or a simple YAML file 

# Read: Why settings are usually kept out of code, and the basics of Python's configparser (or a simple .yaml file with PyYAML). 
# Hands-on: Write a short script that reads a couple of made-up settings (e.g., a name and a number) from a small config.ini or config.yaml file and prints them out.

import configparser
config = configparser.ConfigParser()
config.read("config.ini")

import configparser

config = configparser.ConfigParser()

config.read("config.ini")

name = config["User"]["name"]
age = config["User"].getint("age")

print("Name:", name)
print("Age:", age)
print(type(age))