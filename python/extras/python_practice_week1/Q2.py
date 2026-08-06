from abc import ABC  , abstractmethod
class person(ABC):
    @abstractmethod
    def get_gender(self):
        pass
class Male(person):
    def get_gender(self):
        print("Male")
class Female(person):
    def get_gender(self):
        print("Female")
m=Male()
m.get_gender()
f=Female()
f.get_gender()