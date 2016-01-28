class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.text :card_type
      t.text :primary_registator_username
      t.text :secondary_registrator_username
      t.text :classification
      t.text :collection
      t.text :lookup_field_value
      t.text :lookup_field_type
      t.text :title
      t.integer :year_from
      t.integer :year_to
      t.boolean :no_year, default:false
      t.text :primary_registrator_problem
      t.text :secondary_registrator_problem
      t.json :primary_registrator_values
      t.json :secondary_registrator_values
      t.timestamp :primary_registrator_start
      t.timestamp :secondary_registrator_start
      t.timestamp :primary_registrator_end
      t.timestamp :secondary_registrator_end
      t.text :additional_authors, array:true, default:[]
      t.text :reference_text
      t.integer :ipac_image_id
      t.text :ipac_note
      t.text :ipac_lookup

      t.timestamps null: false
    end
  end
end
