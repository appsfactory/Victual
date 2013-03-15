class AddNotifiedToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :notified, :boolean
  end
end
