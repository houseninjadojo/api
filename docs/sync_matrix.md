# sync matrix

|                  | Arrivy | Auth0 | Hubspot | Stripe |
| ---------------- | ------ | ----- | ------- | ------ |
| CreditCard       |        |       |         |    x   |
| Document         |        |       |    x    |    x   |
| Invoice          |        |       |    x    |    x   |
| PaymentMethod    |        |       |         |    x   |
| Payment          |        |       |         |    x   |
| PromoCode        |        |       |    x    |    x   |
| Property         |   x    |       |    x    |    x   |
| SubscriptionPlan |        |       |         |    x   |
| Subscription     |        |       |         |    x   |
| User             |   x    |   x   |    x    |    x   |
| WorkOrder        |   x    |       |    x    |    x   |

## Arrivy

|                  | Attributes |
| ---------------- | ---------- |
| CreditCard       |            |
| Document         |            |
| Invoice          |            |
| PaymentMethod    |            |
| Payment          |            |
| PromoCode        |            |
| Property         | x |
| SubscriptionPlan |            |
| Subscription     |            |
| User             | x |
| WorkOrder        | x |

## Auth0

### Users

| User                     | Auth0         |
| ------------------------ | ------------- |
| `email`                  | `email`       |
| `first_name`             | `given_name`  |
| `last_name`              | `family_name` |
| `first_name + last_name` | `name`        |

## Hubspot

### Documents

### Invoices

### Users

| User                     | Auth0         |
| ------------------------ | ------------- |
| `email`                  | `email`       |
| `first_name`             | `given_name`  |
| `last_name`              | `family_name` |
| `first_name + last_name` | `name`        |

### WorkOrders

|                  | Attributes                         |
| ---------------- | ---------------------------------- |
| CreditCard       |                                    |
| Document         |  |
| Invoice          |  |
| PaymentMethod    |                                    |
| Payment          |                                    |
| PromoCode        |                                    |
| Property         |                                    |
| SubscriptionPlan |                                    |
| Subscription     |                                    |
| User             | `email`, `first_name`, `last_name` |
| WorkOrder        |                                    |
