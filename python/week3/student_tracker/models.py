from dataclasses import dataclass

@dataclass
class Student:
    name : str
    scores : list[float]

    @property
    def average(self)->float:
        if not self.scores:
            raise ValueError("students has no scores")
        return sum(self.scores)/len(self.scores)

    