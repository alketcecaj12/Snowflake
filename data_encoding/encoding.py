import csv 
import chardet

with open('kyoto_restaurants.csv', 'rb') as file:
    raw_bytes = file.read(32)
    encoding_name = chardet.detect(raw_bytes)['encoding']
    print(encoding_name)
    
with open('kyoto_restaurants.csv', encoding = 'UTF-16') as file:
    rows = list(csv.reader(file))