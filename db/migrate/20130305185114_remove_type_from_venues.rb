class RemoveTypeFromVenues < ActiveRecord::Migration
  def up
    remove_column :venues, :type
    remove_column :groups, :type
    remove_column :users, :type
    add_column :venues, :foodtype, :string
    add_column :groups, :foodtype, :string
    add_column :users, :foodtype, :string
  end

  def down
    add_column :venues, :type, :string
    add_column :groups, :type, :string
    add_column :users, :type, :string
    remove_column :venues, :foodtype
    remove_column :groups, :foodtype
    remove_column :users, :foodtype
  end
end
