class CreateApplications < ActiveRecord::Migration[8.0]
  def change
    create_table :applications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.integer :position_type
      t.text :experience
      t.string :programming_languages
      t.integer :available_hours
      t.string :status

      t.timestamps
    end
  end
end
