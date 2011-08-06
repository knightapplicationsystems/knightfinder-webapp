class AddFeaturedColumnToDeals < ActiveRecord::Migration
  def self.up
    change_table :deals do |t|
      t.boolean :featured, :default => false
    end
  end

  def self.down
    remove_column :deals, :featured
  end
end
