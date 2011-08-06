class CreateCheckins < ActiveRecord::Migration
  def self.up
    create_table :checkins do |t|
      t.integer :event_id
      t.integer :user_id
      t.boolean :employment, :default => false
      t.boolean :employ, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :checkins
  end
end
