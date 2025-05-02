class RecommendationLetter < ApplicationRecord
  belongs_to :course
  
  # Validations
  validates :instructor_name, presence: true
  validates :instructor_email, presence: true, format: { with: /\A[^@\s]+\.[0-9]+@osu\.edu\z/, message: "must be a valid OSU email (name.#@osu.edu)" }
  validates :student_name, presence: true
  validates :student_email, presence: true, format: { with: /\A[^@\s]+\.[0-9]+@osu\.edu\z/, message: "must be a valid OSU email (name.#@osu.edu)" }
  validates :content, presence: true
  
  # Status options
  enum :status, {
    pending: 'pending',
    approved: 'approved',
    rejected: 'rejected'
  }, default: :pending
  
  # Find or create the student user if they don't exist
  after_create :find_or_create_student_user
  
  # Create or update application when recommendation is approved
  after_save :process_application_on_approval, if: -> { saved_change_to_status? && status == 'approved' }
  
  # 监听状态变更
  after_save :log_status_change, if: -> { saved_change_to_status? }
  
  private
  
  def log_status_change
    Rails.logger.info "Recommendation Letter ##{id} status changed to: #{status}"
    Rails.logger.info "Previous status was: #{status_before_last_save}"
  end
  
  def find_or_create_student_user
    user = User.find_by(email: student_email)
    
    unless user
      # Create a temporary password for the new user
      random_password = SecureRandom.hex(8)
      
      # Create the user with student role
      user = User.create!(
        email: student_email,
        password: random_password,
        role: :student,
        approved: true
      )
      
      Rails.logger.info "Created new student user with email: #{user.email}"
      
      # TODO: Send an email notification to the student
      # with instructions to reset their password
    end
  end
  
  def process_application_on_approval
    Rails.logger.info "Processing application after recommendation approval for student: #{student_email}"
    
    # Find the student user
    user = User.find_by(email: student_email)
    
    unless user
      Rails.logger.error "Student user not found with email: #{student_email}"
      # Let's create the user if they don't exist
      random_password = SecureRandom.hex(8)
      user = User.create!(
        email: student_email,
        password: random_password,
        role: :student,
        approved: true
      )
      Rails.logger.info "Created new student user with email: #{user.email}"
    end
    
    # Check if an application already exists
    existing_application = Application.find_by(user_id: user.id, course_id: course_id)
    
    if existing_application
      Rails.logger.info "Found existing application ##{existing_application.id}, status: #{existing_application.status}"
      # Update the existing application if it's pending
      if existing_application.status == 'pending'
        existing_application.update(status: 'approved')
        Rails.logger.info "Updated existing application to approved"
      end
    else
      Rails.logger.info "Creating new application for user #{user.id} and course #{course_id}"
      # Create a new application with default values
      new_application = Application.create!(
        user_id: user.id,
        course_id: course_id,
        position_type: :grader, # Default position type
        experience: "Recommended by #{instructor_name} (#{instructor_email})",
        programming_languages: "Not specified in recommendation",
        available_hours: 5, # Default hours
        status: 'approved' # Auto-approve applications from recommendations
      )
      Rails.logger.info "Created new application ##{new_application.id} with approved status"
    end
  end
end
