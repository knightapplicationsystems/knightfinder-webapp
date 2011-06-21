class AddCityToVenues < ActiveRecord::Migration
  def self.up
    change_table :venues do |t|
      t.string :city
    end
  end

  def self.down
    remove_column :venues, :city
  end
end
