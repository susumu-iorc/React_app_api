class CreateDistances < ActiveRecord::Migration[6.0]
  def change
    create_table :distances do |t|
      t.integer :user_id
      t.string  :place_id
      t.integer :distance
      t.string  :distance_text
      t.integer :duration
      t.string  :duration_text
      t.timestamps
    end
  end
end
