class AddFoodtypeToVenues < ActiveRecord::Migration
  def change
    add_column :venues, :foodtype, :string
  end
end
