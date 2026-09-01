
from bank_account import (
    BankAccount,
    SavingsAccount,
    CurrentAccount
)

#safe deposit
def safe_deposit(account: BankAccount, amount: float) -> None:

    try:
        account.deposit(amount)
        print(f"Deposit of {amount} successful.")

    except ValueError as e:
        print(f"Transaction failed: {e}")

#safe withdrawal
def safe_withdraw(account: BankAccount, amount: float) -> None:

    try:
        account.withdraw(amount)
        print(f"Withdrawal of {amount} successful.")

    except ValueError as e:
        print(f"Transaction failed: {e}")


def main() -> None:
    """Demonstrate BankAccount, SavingsAccount and CurrentAccount."""


    print("PART A - BANKING SYSTEM")
 

# Basic Bank Account
 
    account = BankAccount(
        "ACC001",
        "Tejas",
        5000
    )

    safe_deposit(account, 2000)
    safe_withdraw(account, 1000)

    print("\n--- Bank Account ---")
    print("Account:", account.account_number)
    print("Holder:", account.holder_name)
    print("Balance:", account.get_balance())
    print("Transaction History:")
    print(account.transaction_history)

 # Savings Account 1
   

    savings1 = SavingsAccount(
        "S001",
        "Tejas",
        10000,
        5
    )

    safe_deposit(savings1, 2000)
    safe_withdraw(savings1, 1000)

    savings1.apply_interest()

    print("\n--- Savings Account 1 ---")
    print("Account:", savings1.account_number)
    print("Holder:", savings1.holder_name)
    print("Interest Rate:", savings1.interest_rate)
    print("Balance:", savings1.get_balance())
    print("Transaction History:")
    print(savings1.transaction_history)

    
# Savings Account 2

    savings2 = SavingsAccount(
        "S002",
        "Rahul",
        15000,
        4
    )

    safe_deposit(savings2, 3000)

    # Intentionally invalid withdrawal
    safe_withdraw(savings2, 1100000)

    savings2.apply_interest()

    print("\n--- Savings Account 2 ---")
    print("Account:", savings2.account_number)
    print("Holder:", savings2.holder_name)
    print("Interest Rate:", savings2.interest_rate)
    print("Balance:", savings2.get_balance())
    print("Transaction History:")
    print(savings2.transaction_history)

# Current Account


    current = CurrentAccount(
        "C001",
        "Rahul",
        5000,
        2000
    )

    safe_deposit(current, 1000)
    safe_withdraw(current, 2000)

    print("\n--- Current Account ---")
    print("Account:", current.account_number)
    print("Holder:", current.holder_name)
    print("Overdraft Limit:", current.overdraft_limit)
    print("Balance:", current.get_balance())
    print("Transaction History:")
    print(current.transaction_history)


# Demonstrate Overdraft


    print("\n--- Overdraft Demonstration ---")

    overdraft_account = CurrentAccount(
        "C002",
        "Arun",
        5000,
        2000
    )

    safe_withdraw(overdraft_account, 6000)

    print("Balance after overdraft:",
          overdraft_account.get_balance())

    print("Transaction History:")
    print(overdraft_account.transaction_history)


if __name__ == "__main__":
    main()