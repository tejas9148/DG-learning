# Stack Overflow Developer Survey 2019 - ETL Job

Reads the 2019 survey results, works out the six answers, prints them and saves each one as a csv.

## Folder
```
so_survey_etl/
├── etl.py              main program
├── continents.py       country -> continent lookup
├── requirements.txt
├── data/               put survey_results_public.csv here
└── output/             reports are saved here
```

## Steps to run
1. Download the 2019 survey results from the Stack Overflow survey page and unzip it.
2. Copy `survey_results_public.csv` into the `data` folder.
3. Install pandas:
   ```
   pip install -r requirements.txt
   ```
4. Run the job:
   ```
   python etl.py
   ```
5. Answers show in the console and csv files appear in `output/`.

## What each question uses
| # | Question | Columns used |
|---|----------|--------------|
| 1 | Average age at first line of code | `Age1stCode` |
| 2 | % of developers who know Python, per country | `Country`, `LanguageWorkedWith` |
| 3 | Average salary by continent | `ConvertedComp` (yearly, in USD), `Country` |
| 4 | Most desired language for 2020 | `LanguageDesireNextYear` |
| 5 | Hobby coders by gender and continent | `Hobbyist`, `Gender`, `Country` |
| 6 | Job and career satisfaction by gender and continent | `JobSat`, `CareerSat`, `Gender`, `Country` |

## Gender column
The `survey_results_public.csv` copy I tested with has no gender column at all. In that case reports 5 and 6 are produced by continent only, and the program prints a note saying so. If your copy of the survey file has a gender column, reports 5 and 6 are automatically split into MAN / WOMAN / OTHERS by continent.

## Notes on how the data is treated
- **Gender:** exactly "Man" is MAN, exactly "Woman" is WOMAN. Everything else (non-binary, or more than one answer like "Man;Woman") is OTHERS. People who left gender blank are left out of reports 5 and 6.
- **Age at first code:** answers like "Younger than 5 years" and "Older than 85" are not numbers, so they are skipped.
- **Python percentage:** based on people from that country who answered the languages question.
- **Salary:** simple average of `ConvertedComp`; blank salaries are skipped.
- **Continent:** taken from the country. Answers like "Nomadic" have no continent, so they are left out of the continent reports.
- **Satisfaction:** answers are scored 5 (Very satisfied) down to 1 (Very dissatisfied) and averaged.
