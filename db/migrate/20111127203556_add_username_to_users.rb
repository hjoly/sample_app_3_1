class AddUsernameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :username, :string, :limit => 15

    # A SchemaPlus bug requires commenting out indexes coming from belongs_to associations
    add_index :users, :username, :unique => true

    # The following code is a trick for enabling the addition of a username column that doesn't accept NULL value:
    # Essentially, we add the column without that constraint to the existing users table. Then we
    # assign a default value to that column for all the existing records and finally, we alter the column
    # to be non-null.

    User.reset_column_information
    index = 1

    User.all.each do |user|
      user.username = "#{index}"
      user.save!
      index += 1
    end

    change_column :users, :username, :string, :limit => 15, :null => false
  end
end
