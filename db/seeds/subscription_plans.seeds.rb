SubscriptionPlan.find_or_create_by({
  slug: 'annual',
  name: 'Annual',
  price: '319',
  interval: 'year',
  perk: '1 month free',
  stripe_price_id: 'annual',
})

SubscriptionPlan.find_or_create_by({
  slug: 'monthly',
  name: 'Monthly',
  price: 29,
  interval: 'month',
  perk: 'More flexible',
  stripe_price_id: 'monthly',
})
