class CreateSellers < ActiveRecord::Migration
  def change
    create_table :sellers do |t|
      t.string :name,  null: false
      t.string :email, null: false

      t.timestamps null: false
    end
  end
end
