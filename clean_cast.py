import pandas as pd
import json
import re

# ---------------------------
# CONFIG
# ---------------------------
CSV_FILE = r"movies_metadata.csv"                # input CSV
OUTPUT_FILE = r"movies_metadata_cleaned.csv"    # output CSV
JSON_COLUMNS = ["genres", "production_companies", "production_countries", "spoken_languages"]  # JSON columns
# ---------------------------

# Function to clean/validate JSON strings
def clean_json(val):
    if pd.isna(val):
        return None
    # Replace single quotes with double quotes
    val = val.replace("'", '"')
    # Remove trailing commas before closing braces/brackets
    val = re.sub(r',(\s*[}\]])', r'\1', val)
    # Try parsing to ensure it's valid JSON
    try:
        parsed = json.loads(val)
        return json.dumps(parsed)  # standardized formatting
    except:
        # If still invalid, return the raw string
        return val

# Load CSV
df = pd.read_csv(CSV_FILE)

# Clean JSON columns
for col in JSON_COLUMNS:
    if col in df.columns:
        df[col] = df[col].apply(clean_json)

# Save cleaned CSV
df.to_csv(OUTPUT_FILE, index=False)
print(f"Cleaned CSV saved to {OUTPUT_FILE}")