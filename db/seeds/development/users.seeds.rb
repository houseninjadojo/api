# Set up Users
# Each user is associated with an already-established Auth0 profile and identifier.
# When adding or changing the entries here, be sure that the ids are the same used for Auth0
User.find_or_create_by!(
  id: 'c1022bb5-80f3-4248-918c-48f6eb7114c0',
  first_name: 'Miles',
  last_name: 'Zimmerman',
  phone_number: '+19254514431',
  email: 'miles@houseninja.co',
  gender: 'male',
  auth_zero_user_created: true,
)

User.find_or_create_by!(
  id: '22d8949b-11da-4d13-b4f2-574bede56e0f',
  first_name: 'Achilles',
  last_name: 'Imperial',
  phone_number: '+16467976636',
  email: 'achilles@houseninja.co',
  gender: 'male',
  auth_zero_user_created: true,
)
