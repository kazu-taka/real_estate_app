class House < ActiveRecord::Base
  validates :name,
    presence: true, length: { maximum: 100 }
  validates :price,
    presence: true
  validates :address,
    presence: true
end
