class AddUserAuthenticationFieldsToVenue < ActiveRecord::Migration
  def self.up
    change_table :venues do |t|
      t.string :crypted_password
      t.string :login_email
    end
  end

  def self.down
    remove_column :venues, :crypted_password
    remove_column :venues, :login_email
  end
end
