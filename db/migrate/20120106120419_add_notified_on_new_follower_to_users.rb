class AddNotifiedOnNewFollowerToUsers < ActiveRecord::Migration
  def change
    add_column :users, :notified_on_new_follower, :boolean, :default => true, :null => false
  end
end
