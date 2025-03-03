after 'development:users' do
  miles = User.find_by(email: 'miles@houseninja.co')
  miles_property = miles.properties.find_or_create_by!(
    lot_size: 11325.6,
    home_size: 1954,
    garage_size: 2,
    year_built: 1957,
    estimated_value: '1651400',
    bedrooms: 3,
    bathrooms: 2.5,
    pools: 0,

    street_address1: '3226 Burton Court',
    city: 'Lafayette',
    state: 'CA',
    zipcode: '94549',
  )
end
