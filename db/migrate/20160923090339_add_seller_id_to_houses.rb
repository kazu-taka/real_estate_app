class AddSellerIdToHouses < ActiveRecord::Migration
  def change
    add_reference :houses, :seller, index: true, foreign_key: true
  end
end
