class TertiaryForms < ActiveRecord::Migration
  def change
    add_column :cards, :tertiary_registrator_username, :text
    add_column :cards, :tertiary_registrator_problem, :text
    add_column :cards, :tertiary_registrator_values, :json
    add_column :cards, :tertiary_registrator_start, :datetime
    add_column :cards, :tertiary_registrator_end, :datetime
  end
end
