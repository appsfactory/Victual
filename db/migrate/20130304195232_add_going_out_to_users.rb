class AddGoingOutToUsers < ActiveRecord::Migration
  def change
    add_column :users, :going_out, :boolean
    add_column :users, :has_pref, :boolean
    add_column :users, :accepted, :boolean
    add_column :users, :group_id, :integer
  end
end
