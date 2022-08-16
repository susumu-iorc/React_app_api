class CreateMemos < ActiveRecord::Migration[6.0]
  def change
    create_table :memos do |t|
      t.integer :user_id
      t.string :place_id
      t.text :memo
      t.integer :count
      t.integer :favorite

      t.timestamps
    end
    add_index :memos, [:user_id, :place_id]
    add_index :memos, [:count, :favorite]
  end
end