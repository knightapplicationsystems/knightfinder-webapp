class CreateDeals < ActiveRecord::Migration
  def self.up
    create_table :deals do |t|
      t.integer :id, :null => false
      t.string  :venue_id, :null => false
      t.string  :summary
      t.string  :details
      t.datetime :expires
      t.boolean :active, :default => false
      
      t.timestamps
    end
    add_index :deals, :id
  end

  def self.down
    drop_table :venues
  end
end
