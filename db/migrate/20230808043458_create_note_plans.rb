class CreateNotePlans < ActiveRecord::Migration[6.1]
  def change
    create_table :note_plans do |t|
      t.references :plan, null: false, foreign_key: true
      t.references :note, null: false, foreign_key: true
      t.time :arrival, null: true
      t.time :departure, null: true
      t.timestamps
    end
  end
end
