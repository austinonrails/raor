class AddShoutoutToCheckin < ActiveRecord::Migration
  def change
    add_column :checkins, :shoutout, :string
  end
end
