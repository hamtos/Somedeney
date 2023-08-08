class CreateTags < ActiveRecord::Migration[6.1]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.boolean :is_custom, null: false, default: true
      t.integer :tag_category, null:false, default: 0
      t.timestamps
    end
  end
end
