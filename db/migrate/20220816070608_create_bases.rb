class CreateBases < ActiveRecord::Migration[6.0]
  def change
    create_table :bases do |t|
      t.integer :user_id
      t.text :user_post_code
      t.text :user_pref
      t.text :user_city
      t.text :user_area
      t.string :lat
      t.string :lng
      t.timestamps
    end
  end
end
