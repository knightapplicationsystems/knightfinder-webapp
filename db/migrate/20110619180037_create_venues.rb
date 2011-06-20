class CreateVenues < ActiveRecord::Migration
  def self.up
    create_table :venues do |t|
      t.integer :id, :null => false
      t.string  :name, :null => false
      t.string  :address1
      t.string  :address2
      t.string  :address3
      t.string  :postcode
      t.string  :phone
      t.string  :email
      t.string  :url
      t.string  :longditude
      t.string  :lattitude
      t.boolean :active, :default => false
      
      t.timestamps
    end
    add_index :venues, :id
  end

  def self.down
    drop_table :venues
  end
end
