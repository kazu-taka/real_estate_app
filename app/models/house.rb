class House < ActiveRecord::Base
  belongs_to :seller
  validates :name,
    presence: true, length: { maximum: 100 }
  validates :price,
    presence: true
  validates :address,
    presence: true
end
