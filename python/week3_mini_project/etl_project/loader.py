import pandas as pd
import os

def save_to_csv ( df : pd.DataFrame  , output_path : str)-> None:
    os.makedirs(os.path.dirname(output_path), exist_ok=True)

    df.to_csv(output_path , index=False)