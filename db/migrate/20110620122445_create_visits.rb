class CreateVisits < ActiveRecord::Migration
  def self.up
    create_table :visits do |t|
      t.integer :id, :null => false
      t.integer :venue_id, :null => false
      t.string  :request_uri
      t.string  :remote_ip
      t.string  :user_agent
      t.string  :city
      t.string  :longitude
      t.string  :latitude
      
      t.timestamps
    end
    add_index :visits, :id
  end

  def self.down
    drop_table :visits
  end
end
