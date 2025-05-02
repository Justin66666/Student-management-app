class Application < ApplicationRecord
  belongs_to :user
  belongs_to :course
  belongs_to :section, optional: true

  validates :position_type, presence: true
  validates :experience, presence: true
  validates :programming_languages, presence: true
  validates :available_hours, presence: true, numericality: { greater_than: 0 }

  enum :position_type, {
    grader: 0,
    teaching_assistant: 1,
    lab_assistant: 2
  }

  enum :status, {
    pending: 'pending',
    approved: 'approved',
    rejected: 'rejected'
  }, default: :pending

  # Helper method to check if application is in pending status
  def pending?
    status == 'pending'
  end
  
  # Helper method to get hours per week
  def hours_per_week
    available_hours
  end
end 