class AddKeepToUsers < ActiveRecord::Migration
  def change
    add_column :users, :keep, :boolean
  end
end
