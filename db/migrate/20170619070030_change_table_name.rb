class ChangeTableName < ActiveRecord::Migration[5.1]
  def change
  	drop_table :users_actions
  	create_table :actions_users , :id=>false do |t|
    	t.integer :user_id
    	t.integer :action_id
    end
  end
end
