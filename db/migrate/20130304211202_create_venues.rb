class CreateVenues < ActiveRecord::Migration
  def change
    create_table :venues do |t|
      t.string :name
      t.string :type
      t.integer :distance

      t.timestamps
    end
  end
end
