# Restaurant API

Client needs:

- ordering food
- knowing wht is available
- tracking delivery status

Design the API of an app that answers these needs.

## Formalism

```yaml
[object name]
field: description
...

[procedure name] -> ReturnType
*required field: description
optional field: description
```

## Answer

```yaml
[Ask for menu] -> List of MenuItem
(no information required)

[MenuItem]
id
name: string
price: Price

[Price]
amount: int
currency: string

[Order food] -> OrderID
*list of FoodOrderItem
*delivery address: string
*billing email
discount code: string

[FoodOrderItem]
food-id: foreign key
quantity: int

[OrderID]
id

[Track delivery status] - GET /orders/{order_id}
*required field: order id

[Delivery Status Response]
order status: enum {}
estimated delivery time: int in minutes
price
```

## Evolution

Add the possibility to know what food will be available on a future date.

```yaml
[Ask for menu] - GET /menu?date={date}
date
*returns: list of available items for that date
```
