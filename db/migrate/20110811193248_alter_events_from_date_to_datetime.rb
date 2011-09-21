class AlterEventsFromDateToDatetime < ActiveRecord::Migration
  def change
    change_column :events, :start_date, :datetime
    change_column :events, :end_date, :datetime
  end
end
