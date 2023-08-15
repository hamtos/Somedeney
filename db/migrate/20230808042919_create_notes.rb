class CreateNotes < ActiveRecord::Migration[6.1]
  def change
    create_table :notes do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :title, null: false
      t.text :body, null: true
      t.string :prefecture, null: true
      t.string :city, null: true
      t.string :address, null:true
      t.float :latitude, null: true
      t.float :longitude, null: true
      t.boolean :is_visited, null: false, default: false
      t.boolean :is_deleted, null: false, default: false
      t.integer :star, null: true
      t.timestamps
    end
  end
end
