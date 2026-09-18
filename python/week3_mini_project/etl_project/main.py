import time
import pandas as pd

from extractor import fetch_posts , fetch_users
from transformer import ( add_word_count , categorize , merge_with_users , filter_posts)
from loader import save_to_csv

url = "https://jsonplaceholder.typicode.com"
output_path = "output/etl_result.csv"

def main():
    start_time = time.perf_counter()
    posts = fetch_posts(url)
    users = fetch_users(url)

    if not posts or not users:
        print("etl pipeline stopped : no data was fetched")
        return 
    posts_df = pd.DataFrame(posts)
    users_df = pd.DataFrame(users)

    df=add_word_count(posts_df)
    df = categorize(df)
    df = merge_with_users(df , users_df)
    df = filter_posts(df)

    save_to_csv(df , output_path)
    elapsed_time = time.perf_counter() - start_time

    print("ETL pipeline completed successfully.")
    print(f"Posts fetched: {len(posts)}")
    print(f"Users fetched: {len(users)}")
    print(f"Final rows: {len(df)}")
    print(f"Output: {output_path}")
    print(f"Execution time: {elapsed_time:.2f} seconds")


if __name__ == "__main__":
    main()
