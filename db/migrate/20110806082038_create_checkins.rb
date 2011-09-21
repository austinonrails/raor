class CreateCheckins < ActiveRecord::Migration
  def change
    create_table :checkins do |t|
      t.integer :event_id
      t.integer :user_id
      t.boolean :employment, :default => false, :null => false
      t.boolean :employ, :default => false, :null => false
      t.timestamps
    end
  end
end
