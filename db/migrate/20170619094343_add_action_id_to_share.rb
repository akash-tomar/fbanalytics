class AddActionIdToShare < ActiveRecord::Migration[5.1]
  def change
    add_column :shares, :action_id, :integer
  end
end
