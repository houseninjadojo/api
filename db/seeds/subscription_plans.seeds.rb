SubscriptionPlan.find_or_create_by({
  slug: 'annual',
  name: 'Annual',
  price: '539',
  interval: 'year',
  perk: '1 month free',
})

SubscriptionPlan.find_or_create_by({
  slug: 'monthly',
  name: 'Monthly',
  price: 49,
  interval: 'month',
  perk: 'More flexible',
})
