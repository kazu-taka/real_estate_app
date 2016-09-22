class CreateHouses < ActiveRecord::Migration
  def change
    create_table :houses do |t|
      t.string :name,    null: false, length: { maximum: 100 }
      t.integer :price,  null: false
      t.string :address, null: false
      t.text :note

      t.timestamps null: false
    end
  end
end
