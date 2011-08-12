class AlterEventsFromDateToDatetime < ActiveRecord::Migration
  def self.up
    change_column :events, :start_date, :datetime
    change_column :events, :end_date, :datetime
  end

  def self.down
    change_column :events, :start_date, :date
    change_column :events, :end_date, :date
  end
end
