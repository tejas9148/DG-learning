import pandas as pd
import os
import re
import sys

source = sys.argv[1]

if "docs.google.com/spreadsheets" in source:
    sheet_id = re.search(r"/d/([\w-]+)", source).group(1)
    file = f"https://docs.google.com/spreadsheets/d/{sheet_id}/export?format=xlsx"
    folder = sheet_id
else:
    # Local file
    file = source
    folder = os.path.splitext(os.path.basename(source))[0]

# Create output folder
os.makedirs(folder, exist_ok=True)

# Read all sheets
sheets = pd.read_excel(file, sheet_name=None)

# Convert each sheet to CSV
for sheet_name, data in sheets.items():
    csv_file = os.path.join(folder, sheet_name + ".csv")
    data.to_csv(csv_file, index=False)

print("Conversion completed!")