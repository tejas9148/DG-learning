# SQL Information Extraction
# Write a python script that will extract information from a SQL file.
# Input:
# $ python extraction.py sample_stored_procedure.sql
# Output:
# sample_stored_procedure.json
# Hint: Use regex

import re
import json
import sys
import os

# Get SQL file name from command line
if len(sys.argv) != 2:
    print("Usage: python extraction.py <file.sql>")
    sys.exit(1)

sql_file = sys.argv[1]

if not os.path.isfile(sql_file):
    print("File not found:", sql_file)
    sys.exit(1)

# Read SQL file
with open(sql_file, "r") as file:
    sql = file.read()

# Extract procedure names along with their parameters
procedure_matches = re.findall(
    r"CREATE\s+(?:OR\s+REPLACE\s+)?PROCEDURE\s+`?(\w+)`?\s*\((.*?)\)\s*BEGIN",
    sql,
    re.IGNORECASE | re.DOTALL
)

procedures = []

for name, params_text in procedure_matches:
    parameters = []

    # split on commas, but not the comma inside something like DECIMAL(10,2)
    for part in re.split(r",(?![^()]*\))", params_text):
        part = " ".join(part.split())

        match = re.match(r"(?:(IN|OUT|INOUT)\s+)?(\w+)\s+(.+)", part, re.IGNORECASE)
        if match:
            mode, param_name, param_type = match.groups()
            parameters.append({
                "mode": (mode or "IN").upper(),
                "name": param_name,
                "type": param_type.upper()
            })

    procedures.append({
        "name": name,
        "parameters": parameters
    })

# Extract function names
functions = re.findall(
    r"CREATE\s+(?:OR\s+REPLACE\s+)?FUNCTION\s+`?(\w+)`?",
    sql,
    re.IGNORECASE
)

# Extract table names
tables = re.findall(
    r"(?:FROM|JOIN|INSERT\s+INTO|UPDATE|DELETE\s+FROM)\s+`?(\w+)`?",
    sql,
    re.IGNORECASE
)

# Remove duplicate table names but keep the order
tables = list(dict.fromkeys(tables))

# Store extracted information
data = {
    "procedures": procedures,
    "functions": functions,
    "tables": tables
}

# Create output file name
output_file = os.path.splitext(sql_file)[0] + ".json"

# Write JSON file
with open(output_file, "w") as file:
    json.dump(data, file, indent=4)

print("Information extracted successfully!")
print("Output:", output_file)