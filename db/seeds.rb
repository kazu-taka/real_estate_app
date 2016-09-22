30.times do
  House.create(
    name:    'メゾン' + ForgeryJa(:name).last_name,
    price:   ForgeryJa(:monetary).popularity_money,
    address: ForgeryJa(:address).full_address,
    note:    Faker::Lorem.paragraphs
  )
end