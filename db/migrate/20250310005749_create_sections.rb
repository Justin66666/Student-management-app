class CreateSections < ActiveRecord::Migration[8.0]
  def change
    create_table :sections do |t|
      t.string :number
      t.string :instructor_name
      t.string :schedule
      t.string :location
      t.integer :current_enrollment
      t.integer :max_enrollment
      t.references :course, null: false, foreign_key: true

      t.timestamps
    end
  end
end
