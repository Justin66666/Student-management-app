class AddFieldsToCourses < ActiveRecord::Migration[8.0]
  def change
    add_column :courses, :term, :string
    add_column :courses, :campus, :string
    add_column :courses, :subject, :string
    add_column :courses, :catalog_number, :string
    add_column :courses, :course_id, :string
    add_column :courses, :section_number, :string
    add_column :courses, :component, :string
    add_column :courses, :class_number, :string
  end
end
