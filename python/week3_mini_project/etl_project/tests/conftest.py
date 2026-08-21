# pytest fixture : 
import pandas as pd
import pytest

@pytest.fixture
def sample_posts():
    data = {
      "id": [1, 2, 3, 4, 5],
        "userId": [1, 2, 1, 3, 2],
        "title": [
            "Short Post",
            "Medium Post",
            "Long Post",
            "Another Post",
            "Final Post"
        ],
        "body": [
            "Python is easy to learn",
            "Python is a powerful programming language used for data engineering",
            "Python is a powerful programming language and it is widely used for building applications data pipelines machine learning systems and automation tools",
            "Hello world",
            "Data engineering involves collecting transforming and storing data efficiently"
        ]  
    }
    return pd.DataFrame(data)

@pytest.fixture
def sample_users():
    data = {
        "id": [1, 2, 3],
        "name": [
            "Leanne Graham",
            "Ervin Howell",
            "Clementine Bauch"
        ],
        "username": [
            "Bret",
            "Antonette",
            "Samantha"
        ],
        "email": [
            "leanne@example.com",
            "ervin@example.com",
            "clementine@example.com"
        ]
    }

    return pd.DataFrame(data)