
# Topic: pandas: read_csv, groupby, merge + numpy basics

# You have students.csv (student_id, name, class) and scores.csv
# (student_id, subject, score):
# (a) Read both into DataFrames and merge on student_id.
# (b) Use groupby to find average score per subject and per student.
# (c) Add a grade column: 'A' >= 85, 'B' >= 70, 'C' >= 55, 'F' otherwise.
# (d) Use numpy: mean, standard deviation, 75th percentile of all scores
# (e) Predict the output:
# import pandas as pd
# data = {
#     'name': ['A', 'B', 'A', 'B'],
#     'score': [80, 90, 70, 85]
# }
# df = pd.DataFrame(data)
# result = df.groupby('name')['score'].mean()
# print(result.to_dict())
#--------------------------------------------
# (a) read and merge
import pandas as pd 
import numpy as np
students = pd.read_csv("students.csv")
scores=pd.read_csv("scores.csv")
result = pd.merge(students , scores , on ="student_id")
print(result)
#----------------------------------------------
# (b) group by
print(result.groupby("subject")["score"].mean())
print(result.groupby("name")["score"].mean())
#-----------------------------------------------
# (c) grade column
def get_grade(score):
    if score >= 85:
        return "A"
    elif score >= 70:
        return "B"
    elif score >= 55:
        return "C"
    else:
        return "F"

result["grade"] = result["score"].apply(get_grade)

print(result)

#-------------------------------------------------
# (d)  numpy 
print("Mean:", np.mean(result["score"]))
print("Standard deviation:", np.std(result["score"]))
print("75th percentile:", np.percentile(result["score"], 75))

#---------------------------------------------------
# (e) predict output
# predicted output:
#   {'A': 75.0 , 'B': 87.5}
data={
    'name':['A','B','A','B'],
    'score':[80,90,70,85]
}
df=pd.DataFrame(data)
result=df.groupby('name')['score'].mean()
print(result.to_dict())

# Actual output:
# {'A': 75.0, 'B': 87.5}