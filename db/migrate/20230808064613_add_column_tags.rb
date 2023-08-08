class AddColumnTags < ActiveRecord::Migration[6.1]
  def change
    add_column :tags, :customer_id, :integer, null: false
  end
end
