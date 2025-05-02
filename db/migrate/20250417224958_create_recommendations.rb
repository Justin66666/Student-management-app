class CreateRecommendations < ActiveRecord::Migration[8.0]
  def change
    create_table :recommendations do |t|
      t.integer :instructor_id
      t.string :student_email
      t.integer :course_id
      t.text :content
      t.string :status
      t.string :recommendation_type

      t.timestamps
    end
  end
end
