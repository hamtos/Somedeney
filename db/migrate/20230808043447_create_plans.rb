class CreatePlans < ActiveRecord::Migration[6.1]
  def change
    create_table :plans do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :name, null:false, default: "計画"
      t.boolean :is_complete, null: false, default: false
      t.timestamps
    end
  end
end
