import pandas as pd
from transformer import add_word_count , categorize , filter_posts , merge_with_users
import pytest

def test_add_word_count(sample_posts):
    result = add_word_count(sample_posts)
    assert "word_count" in result.columns
    assert result["word_count"].tolist()==[5,10,22,2,9]
@pytest.mark.parametrize(
    "word_count, expected_category",
    [
        (10, "short"),
        (29, "short"),
        (30, "medium"),
        (50, "medium"),
        (51, "long"),
        (100, "long"),
    ]
)


def test_categorize_post(sample_posts, word_count, expected_category):
    df = sample_posts.copy()
    df["word_count"] = word_count

    result = categorize(df)

    assert result["category"].iloc[0] == expected_category

def test_filter_posts(sample_posts):
    df=sample_posts.copy()
    df["word_count"]=[5,10,22,35,40]
    result = filter_posts(df)
    assert result["word_count"].tolist()==[35,40]

def test_merge_with_users(sample_posts , sample_users):
    result = merge_with_users(sample_posts , sample_users)
    assert "name" in result.columns
    assert result.loc[result["userId"]==1 , "name"].iloc[0]=="Leanne Graham"