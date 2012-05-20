class AddRafflrToCheckin < ActiveRecord::Migration
  def change
    add_column :checkins, :rafflr, :boolean
  end
end
