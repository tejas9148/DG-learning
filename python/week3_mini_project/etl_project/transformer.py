#  transform data 
# (1)  add_word_count
import pandas as pd 
def add_word_count(df : pd.DataFrame)->pd.DataFrame:
    df=df.copy()
    df["word_count"]=df["body"].str.split().str.len()
    return df

# (2) categorize_post
def categorize(df:pd.DataFrame)->pd.DataFrame:
    df=df.copy()
    def categorize_word_count(word_count):
        if word_count<30:
            return "short"
        elif word_count <=50:
            return "medium"
        else:
            return "long"

    df["category"]=df["word_count"].apply(categorize_word_count)
    return df

# (3) merge with users
def merge_with_users(posts_df : pd.DataFrame , users_df : pd.DataFrame)-> pd.DataFrame:
    merged_df = posts_df.merge(
        users_df , left_on = "userId" , right_on ="id" , how = "left" , suffixes=("","_user")
    )
    return merged_df

# (4) filter posts
def filter_posts(df :pd.DataFrame , min_words : int=30 )->pd.DataFrame:
    return df[df["word_count"]>= min_words].copy()