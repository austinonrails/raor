class AddEmployerAndRememberEmployerToUsers < ActiveRecord::Migration
  def change
    add_column :users, :employer, :string
    add_column :checkins, :employer, :string
    add_column :users, :remember_employer, :boolean, :default => false
  end
end
