class CreateCourses < ActiveRecord::Migration[8.0]
  def change
    create_table :courses do |t|
      t.integer :course_number
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
