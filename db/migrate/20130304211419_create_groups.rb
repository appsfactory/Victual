class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.integer :venue_id
      t.integer :start
      t.integer :end
      t.integer :dist
      t.integer :type

      t.timestamps
    end
  end
end
