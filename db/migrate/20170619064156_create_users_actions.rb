class CreateUsersActions < ActiveRecord::Migration[5.1]
  drop_table :actions
  def change
  	create_table :actions do |t|
    	t.integer :post_id
    end
    create_table :users_actions, :id=>false do |t|
    	t.integer :user_id
    	t.integer :action_id
    end
  end
end
