class CreateCheckins < ActiveRecord::Migration
  def self.up
    create_table :checkins, :id => false do |t|
      t.integer :event_id
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :checkins
  end
end
