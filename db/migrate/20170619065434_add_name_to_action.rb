class AddNameToAction < ActiveRecord::Migration[5.1]
  def change
  	drop_table :actions
  	create_table :actions do |t|
    	t.integer :post_id
    	t.string :name
    end
  end
end
