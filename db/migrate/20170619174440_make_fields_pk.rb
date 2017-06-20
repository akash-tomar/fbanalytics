class MakeFieldsPk < ActiveRecord::Migration[5.1]
  def change
  	add_index :posts, :post_id, unique: true
  	add_index :users, :facebook_id, unique: true
  end
end
