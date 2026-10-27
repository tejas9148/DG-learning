import pandas as pd
from continents import get_continent

df = pd.read_csv("survey_results_public.csv")

# Clean the columns
df["Age1stCode"] = pd.to_numeric(df["Age1stCode"], errors="coerce")
df["ConvertedComp"] = pd.to_numeric(df["ConvertedComp"], errors="coerce")
df["Continent"] = df["Country"].apply(get_continent)

# Only people with a known continent are used for the continent reports
known = df[df["Continent"] != "Unknown"].copy()


# Gender: MAN, WOMAN or OTHERS (blank answers are left out)
def gender_category(gender):
    if pd.isna(gender):
        return None
    if gender == "Man":
        return "MAN"
    if gender == "Woman":
        return "WOMAN"
    return "OTHERS"      # non-binary, or more than one answer like "Man;Woman"


if "Gender" in known.columns:
    known["Gender_Category"] = known["Gender"].apply(gender_category)
    group_by = ["Gender_Category", "Continent"]
else:
    print("NOTE: this csv has no gender column, so Q5 and Q6 are by continent only.\n")
    group_by = ["Continent"]


# (Q1) Average age when developers wrote their first line of code
average_age = round(df["Age1stCode"].mean(), 2)
print("Q1: Average age at first line of code:", average_age)


# (Q2) Percentage of developers who knew Python in each country
answered = df.dropna(subset=["Country", "LanguageWorkedWith"]).copy()
answered["KnowsPython"] = answered["LanguageWorkedWith"].str.split(";").apply(
    lambda languages: "Python" in languages
)

country_report = (
    answered.groupby("Country")["KnowsPython"].mean() * 100
).round(2).sort_values(ascending=False).reset_index(name="Python_Percentage")

print("\nQ2: Python percentage by country")
print(country_report)
country_report.to_csv("q2_python_by_country.csv", index=False)


# (Q3) Average salary of developers by continent
continent_report = known.groupby("Continent")["ConvertedComp"].mean().round(2)
continent_report = continent_report.sort_values(ascending=False).reset_index(name="Average_Salary")

print("\nQ3: Average salary by continent")
print(continent_report)
continent_report.to_csv("q3_average_salary_by_continent.csv", index=False)


# (Q4) Most desired programming language for 2020
languages = df["LanguageDesireNextYear"].dropna().str.split(";").explode()
language_report = languages.value_counts().reset_index()
language_report.columns = ["Programming_Language", "Developer_Count"]

print("\nQ4: Most desired programming language for 2020:", language_report.iloc[0]["Programming_Language"])
language_report.to_csv("q4_desired_programming_languages_2020.csv", index=False)


# (Q5) People who code as a hobby
hobby_report = known[known["Hobbyist"] == "Yes"].groupby(group_by).size().reset_index(name="Hobbyist_Count")

print("\nQ5: Hobby coders")
print(hobby_report)
hobby_report.to_csv("q5_hobbyist_report.csv", index=False)


# (Q6) Job and career satisfaction (1 = very dissatisfied ... 5 = very satisfied)
satisfaction_mapping = {
    "Very dissatisfied": 1,
    "Slightly dissatisfied": 2,
    "Neither satisfied nor dissatisfied": 3,
    "Slightly satisfied": 4,
    "Very satisfied": 5,
}
known["JobSat_Score"] = known["JobSat"].map(satisfaction_mapping)
known["CareerSat_Score"] = known["CareerSat"].map(satisfaction_mapping)

satisfaction_report = known.groupby(group_by).agg(
    Average_Job_Satisfaction=("JobSat_Score", "mean"),
    Average_Career_Satisfaction=("CareerSat_Score", "mean"),
).round(2).reset_index()

print("\nQ6: Satisfaction")
print(satisfaction_report)
satisfaction_report.to_csv("q6_satisfaction_report.csv", index=False)