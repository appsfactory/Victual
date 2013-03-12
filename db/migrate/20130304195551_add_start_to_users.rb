class AddStartToUsers < ActiveRecord::Migration
  def change
    add_column :users, :start, :int
    add_column :users, :end, :int
  end
end
