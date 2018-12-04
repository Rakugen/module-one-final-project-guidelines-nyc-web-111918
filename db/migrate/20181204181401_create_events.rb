class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
      t.string :name
      t.datetime :date
      t.string :location #city, state
      t.string :venue
      t.string :attractions
      t.integer :min_price
      t.string :classification
    end
  end
end
