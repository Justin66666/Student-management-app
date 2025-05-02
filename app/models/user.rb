class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Roles
  enum :role, { student: 0, instructor: 1, admin: 2 }

  # Associations
  has_many :applications, dependent: :destroy

  # Validations
  validates :email, presence: true, format: { with: /\A[^@\s]+\.[0-9]+@osu\.edu\z/, message: "must be a valid OSU email (name.#@osu.edu)" }
  validates :role, presence: true

  # Callbacks
  after_initialize :set_default_role, if: :new_record?
  before_create :set_approved_status

  # Active for authentication check
  def active_for_authentication?
    super && approved?
  end

  def inactive_message
    approved? ? super : :not_approved
  end

  private

  def set_default_role
    self.role ||= :student
  end

  def set_approved_status
    # Automatically approve students, require approval for instructors and admins
    self.approved = true if student?
  end
end
