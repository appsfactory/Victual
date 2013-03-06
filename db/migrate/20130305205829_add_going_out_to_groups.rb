class AddGoingOutToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :going_out, :boolean
  end
end
