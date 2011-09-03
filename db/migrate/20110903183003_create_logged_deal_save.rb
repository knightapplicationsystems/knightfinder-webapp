class CreateLoggedDealSave < ActiveRecord::Migration
  def self.up
    create_table :logged_deal_saves do |t|
      t.integer :id, :null => false
      t.string  :request_uri
      t.string  :remote_ip
      t.string  :user_agent
      t.integer :venue_id
      t.integer :deal_id
      t.string  :deal_summary
      
      t.timestamps
    end
    add_index :logged_deal_saves, :id
  end

  def self.down
    drop_table :logged_deal_saves
  end
end
