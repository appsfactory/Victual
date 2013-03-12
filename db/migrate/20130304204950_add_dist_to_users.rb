class AddDistToUsers < ActiveRecord::Migration
  def change
    add_column :users, :dist, :int
  end
end
