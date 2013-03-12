class AddDistStringToVenues < ActiveRecord::Migration
  def change
    add_column :venues, :distString, :string
  end
end
