class CreateHouses < ActiveRecord::Migration
  def change
    create_table :houses do |t|
      t.string :name
      t.integer :price
      t.string :address
      t.text :note

      t.timestamps null: false
    end
  end
end
