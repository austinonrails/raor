class AddHiddenToCheckins < ActiveRecord::Migration
  def change
    add_column :checkins, :hidden, :boolean, :default => false, :null => false
  end
end
