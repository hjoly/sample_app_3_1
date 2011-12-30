class CreateRelationships < ActiveRecord::Migration
  def self.up
    create_table :relationships do |t|
      t.integer :follower_id, :null => false
      t.integer :followed_id, :null => false

      t.timestamps
    end
    # A SchemaPlus bug requires commenting out indexes coming from belongs_to associations
    add_index :relationships, :follower_id
    add_index :relationships, :followed_id

    add_index :relationships, [:follower_id, :followed_id], :unique => true
  end

  def self.down
    drop_table :relationships
  end
end
