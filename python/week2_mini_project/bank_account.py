class BankAccount:
    def __init__(self , account_number:str, holder_name :str , balance : float=0.0 ):
        self.account_number = account_number
        self.holder_name = holder_name
        self._balance=balance
        self.transaction_history=[]

    def deposit(self , amount:float)->None:
        if amount <=0:
            raise ValueError("Deposit amount must be positive")
        self._balance+=amount
        self.transaction_history.append({
            "type":"deposit",
            "amount":amount,
            "balance":self._balance
        })

    def withdraw(self , amount:float)->None:
        if amount<=0:
            raise ValueError("withdrawal amount should be positive")
        if amount > self._balance:
            raise ValueError("insufficient balance")
        self._balance-=amount
        self.transaction_history.append({
            "type":"withdrawal",
            "amount":amount,
            "balance":self._balance
        })
    def get_balance(self)->float:
        return self._balance
    @property
    def balance(self) -> float:
        return self._balance
    
    def get_transaction_history(self)->list:
        return self.transaction_history

class CurrentAccount(BankAccount):
    def __init__(self , account_number: str, holder_name: str, balance: float, overdraft_limit: float):
        super().__init__(account_number , holder_name , balance)
        if overdraft_limit<0:
            raise ValueError("Overdraft limit cannot be negative")
        self.overdraft_limit  = overdraft_limit
    def withdraw(self, amount:float)->None:
        if amount<=0:
            raise ValueError("withdrawal amount must be positive")
        if amount > self._balance+self.overdraft_limit:
            raise ValueError("withdrawal exceeds overdraft limit")
        self._balance-=amount

        self.transaction_history.append({
            "type":"withdrawal",
            "amount":amount,
            "balance":self._balance
        })     

class SavingsAccount(BankAccount):
    def __init__(self , account_number: str,holder_name: str,balance: float,interest_rate: float):
        super().__init__(account_number , holder_name , balance)
        if interest_rate<0:
                    raise ValueError("interest rate cannot be negative")
        self.interest_rate = interest_rate
        

    def apply_interest(self)->None:
        interest=self._balance*self.interest_rate/100
        self._balance+=interest

        self.transaction_history.append({
            "type":"interest",
            "amount":interest,
            "balance":self._balance
        })    