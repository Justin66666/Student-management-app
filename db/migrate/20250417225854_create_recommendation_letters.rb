class CreateRecommendationLetters < ActiveRecord::Migration[8.0]
  def change
    create_table :recommendation_letters do |t|
      t.string :instructor_name
      t.string :instructor_email
      t.string :student_name
      t.string :student_email
      t.references :course, null: false, foreign_key: true
      t.text :content
      t.string :status

      t.timestamps
    end
  end
end
