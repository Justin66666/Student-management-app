class Section < ApplicationRecord
  belongs_to :course
  has_many :applications, dependent: :destroy
  
  # Add validations as needed
  validates :number, presence: true
  validates :instructor_name, presence: true
  validates :schedule, presence: true
  validates :location, presence: true
  validates :current_enrollment, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :max_enrollment, presence: true, numericality: { only_integer: true, greater_than: 0 }
  
  # Get all approved grader applications for this section
  def graders
    applications.where(status: 'approved')
  end
end 