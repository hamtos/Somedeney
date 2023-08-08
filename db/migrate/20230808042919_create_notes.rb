class CreateNotes < ActiveRecord::Migration[6.1]
  def change
    create_table :notes do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :title, null: false
      t.text :body, null: false
      t.string :prefecture, null: false
      t.string :city, null: false
      t.float :latitude, null: false
      t.float :longitude, null: false
      t.boolean :is_visited, null: false, default: false
      t.integer :star, null: true
      t.timestamps
    end
  end
end
