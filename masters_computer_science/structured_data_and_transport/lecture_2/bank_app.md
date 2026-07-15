# Scenario - Scrooge McDuck Bank App

Scrooge McDuck wants to draw in more customers by modernizing by providing a new bank app.

Basic Features:

- Users can deposit money in accounts they own
- Users can withdraw money from the accounts

```yaml
[users]
-------
user_id(PK)
name
email
password

[accounts]
----------
account_id(PK)
amount
currency
user_id(FK)
```

- When a new user is registered, he/she provides their email.
- A new record is created in the user table.
- When they open a new account, a new record for this account and given to the users.
- A unique ID is generated for this account and given to the user.
- Users will have to rpovide this ID if they want to deposit or withdrew.
- When users withdraw, the app checks if the requested amount is lower or equal to the available amount.

```yaml
[transactions]
--------------
user_id(FK)
amount
currency
transaction_id(PK)
account_id(FK)
timestamp
type - WITHDRAW, DEPOSIT
```

> The app makes aure that the user logged in can only withdraw money from the
> accounts they own.

## Evolution

New Features and suggestions:

### History of Transactions

- A user should be able to see past transactions for his/her accounts.

```sql
select transaction_id, amount, currency,
user_id, account_id, type 
from transactions where user_id = '$user_id';
```

- User would be able to filter out a specific account for the history.

### Different kinds of Accounts

- There can be different types of accounts like SAVINGS, CURRENT, PENSION and etc.

```yaml
[accounts]
----------
account_id(PK)
amount
currency
user_id(FK)
type - SAVINGS, CURRENT and PENSION
```

- User cannot withdraw amount more than 1200$ every month from a PENSION account.
- User have a transaction limit in SAVINGS account
- No transaction fees on CURRENT account

### Interest Rates

```yaml
[users]
-------
user_id(PK)
name
email
password
type - STUDENT, BUSINESS_OWNER, SENIOR_CITIZENS

[loans]
loan_id(PK)
user_id(FK)
amount
currency
rate_id(FK)

[interest_rates]
interest_rate_id(PK)
rate
user_type
```

- Users can take loans from the bank
- The Interest Rates depend on the User Type

### Payment Classification

- User should be able to classify his/her transactions into categories
- Categories can also have parent. Ex: Bills would be a parent for Telephone Bill

```yaml
[payment-categories]
category_id(PK)
name
color
parent-category(FK)

[transactions]
user_id(FK)
amount
currency
transaction_id(PK)
account_id(FK)
timestamp
type - WITHDRAW, DEPOSIT
payment_category_id(FK)
```
