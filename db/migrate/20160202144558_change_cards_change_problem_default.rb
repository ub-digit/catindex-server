class ChangeCardsChangeProblemDefault < ActiveRecord::Migration
  def change
    change_column_default :cards, :primary_registrator_problem, ''
    change_column_default :cards, :secondary_registrator_problem, ''
    change_column_default :cards, :tertiary_registrator_problem, ''
    execute <<-SQL
      update cards set primary_registrator_problem='' where primary_registrator_problem is null
    SQL
    execute <<-SQL
      update cards set secondary_registrator_problem='' where secondary_registrator_problem is null
    SQL
    execute <<-SQL
      update cards set tertiary_registrator_problem='' where tertiary_registrator_problem is null
    SQL
  end
end
