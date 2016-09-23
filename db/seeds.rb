20.times do
  Seller.create(
    name: ForgeryJa(:name).full_name,
    email: Faker::Internet.free_email
  )
end

100.times do
  House.create(
    name:    'メゾン' + ForgeryJa(:name).last_name,
    price:   ForgeryJa(:monetary).popularity_money,
    address: ForgeryJa(:address).full_address,
    note:    Faker::Lorem.paragraphs,
    seller_id: rand(1..20)
  )
end

