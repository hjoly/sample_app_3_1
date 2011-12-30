class AddPasswordToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :encrypted_password, :string, :limit => 50
  end

  def self.down
    remove_column :users, :encrypted_password
  end
end
