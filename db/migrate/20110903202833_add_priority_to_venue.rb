class AddPriorityToVenue < ActiveRecord::Migration
  def self.up
    change_table :venues do |t|
      t.integer :priority, null: false, default: 0
    end
  end

  def self.down
    remove_column :venues, :priority
  end
end
