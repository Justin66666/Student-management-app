class AddPrerequisitesToCourses < ActiveRecord::Migration[8.0]
  def change
    add_column :courses, :prerequisites, :text
  end
end
