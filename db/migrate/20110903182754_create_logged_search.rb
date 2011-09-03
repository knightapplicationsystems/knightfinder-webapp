class CreateLoggedSearch < ActiveRecord::Migration
  def self.up
    create_table :logged_searches do |t|
      t.integer :id, :null => false
      t.string  :request_uri
      t.string  :remote_ip
      t.string  :user_agent
      t.string  :location
      t.string  :limit
      t.string  :query
      
      t.timestamps
    end
    add_index :logged_searches, :id
  end

  def self.down
    drop_table :logged_searches
  end
end
