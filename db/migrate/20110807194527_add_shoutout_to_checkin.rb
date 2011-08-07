class AddShoutoutToCheckin < ActiveRecord::Migration
  def self.up
    add_column :checkins, :shoutout, :string
  end

  def self.down
    remove_column :checkins, :shoutout
  end
end
