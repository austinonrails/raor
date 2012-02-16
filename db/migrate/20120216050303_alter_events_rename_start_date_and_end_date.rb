class AlterEventsRenameStartDateAndEndDate < ActiveRecord::Migration
  def change
    rename_column :events, :start_date, :start_datetime
    rename_column :events, :end_date, :end_datetime
  end
end
