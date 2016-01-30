class ChangeColumnPrimaryRegistratorUsername < ActiveRecord::Migration
  def change
    rename_column :cards, :primary_registator_username, :primary_registrator_username
  end
end
