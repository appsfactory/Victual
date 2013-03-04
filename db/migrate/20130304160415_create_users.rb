class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.boolean :matched
      t.string :type
      t.string :distance
      t.string :timeStart
      t.string :timeEnd

      t.timestamps
    end
  end
end
