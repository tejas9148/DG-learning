""" Titanic dataset analysis"""

import pandas as pd
import numpy as np

#load data
def load_data(file_path: str) -> pd.DataFrame:

    return pd.read_csv(file_path)

# clean data
def clean_data(df: pd.DataFrame) -> pd.DataFrame:

    df = df.copy()

    # Handle missing Age values using median
    df["Age"] = df["Age"].fillna(
        df["Age"].median()
    )

    # Handle missing Embarked values using mode
    df["Embarked"] = df["Embarked"].fillna(
        df["Embarked"].mode()[0]
    )

    # Drop irrelevant columns
    df = df.drop(
        columns=["Name", "Ticket", "Cabin"]
    )

    return df

# using group by for analysis
def groupby_analysis(df: pd.DataFrame) -> None:

    # Survival rate by passenger class
    survival_by_class = (
        df.groupby("Pclass")["Survived"]
        .mean()
        .mul(100)
    )

    print("\nSurvival Rate by Passenger Class (%)")
    print(survival_by_class)

    # Survival rate by gender
    survival_by_gender = (
        df.groupby("Sex")["Survived"]
        .mean()
        .mul(100)
    )

    print("\nSurvival Rate by Gender (%)")
    print(survival_by_gender)

# using merge
def merge_analysis(df: pd.DataFrame) -> None:

# Create passenger information table
    passenger_info = df[
        [ "PassengerId", "Pclass", "Sex", "Age"]
    ]

# Create survival information table
    survival_info = df[
        ["PassengerId","Survived"]
    ]

# Merge both tables using PassengerId
    merged_df = pd.merge(
        passenger_info,
        survival_info,
        on="PassengerId",
        how="inner"
    )

    print("\nMerged Data")
    print(
        merged_df.head().to_string(index=False)
    )

    print("\nMerged Data Shape:")
    print(merged_df.shape)

# top 10 records
def top_10_analysis(df: pd.DataFrame) -> None:

    top_10_fares = df.nlargest(
        10,
        "Fare"
    )

    print("\nTop 10 Passengers by Fare")

    print(
        top_10_fares[
            [ "PassengerId", "Pclass",  "Sex", "Age", "Fare"]
        ].to_string(index=False)
    )


def filtered_analysis(df: pd.DataFrame) -> None:

# Male passengers in first class
    filtered = df[
        (df["Sex"] == "male") &
        (df["Pclass"] == 1)
    ]

    print("\nMale Passengers in First Class")

    print(
        filtered[
            [ "PassengerId","Survived", "Pclass","Sex","Age","Fare" ]
        ].head(10).to_string(index=False))
    
#numpy analysis
def numpy_analysis(df: pd.DataFrame) -> None:

    age = df["Age"].to_numpy()
    fare = df["Fare"].to_numpy()

# Mean
    mean_age = np.mean(age)

# Standard deviation
    std_age = np.std(age)

# 25th percentile
    percentile_25 = np.percentile(
        age,
        25
    )

# 75th percentile
    percentile_75 = np.percentile(
        age,
        75
    )

# Correlation between Age and Fare
    correlation = np.corrcoef(
        age,
        fare
    )[0, 1]

    print("\nNumPy Statistics")

    print("Mean Age:", mean_age)

    print(
        "Standard Deviation of Age:",
        std_age
    )

    print(
        "25th Percentile of Age:",
        percentile_25
    )

    print(
        "75th Percentile of Age:",
        percentile_75
    )

    print(
        "Correlation between Age and Fare:",
        correlation
    )


def main() -> None:
    print("PART B - TITANIC DATA ANALYSIS")
    # Load dataset
    df = load_data("titanic.csv")

    print("\nOriginal Dataset Shape:")
    print(df.shape)

    print("\nOriginal Dataset Information:")
    df.info()

    print("\nFirst 5 Rows:")
    print(df.head())

# Missing values before cleaning
    print("\nMissing Values Before Cleaning:")
    print(df.isnull().sum())

# Clean dataset
    df = clean_data(df)

# Missing values after cleaning
    print("\nMissing Values After Cleaning:")
    print(df.isnull().sum())

    print("\nCleaned Dataset Shape:")
    print(df.shape)

# Pandas groupby
    groupby_analysis(df)

# Pandas merge
    merge_analysis(df)

# Pandas top 10
    top_10_analysis(df)

# Pandas filtering
    filtered_analysis(df)

# NumPy statistics
    numpy_analysis(df)


if __name__ == "__main__":
    main()