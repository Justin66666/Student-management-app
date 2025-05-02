class Course < ApplicationRecord
  # Associations
  has_many :applications, dependent: :destroy
  has_many :sections, dependent: :destroy
  has_many :recommendation_letters, dependent: :destroy

  # Pagination
  paginates_per 10

  # Validations
  validates :course_number, presence: true
  validates :title, presence: true
  validates :term, presence: true
  validates :campus, presence: true
  validates :subject, presence: true, inclusion: { in: ['CSE'] }

  # Scopes
  scope :by_level, ->(level) { where("course_number >= ? AND course_number < ?", level * 1000, (level + 1) * 1000) }
  scope :search_by_term, ->(term) { where(term: term) if term.present? }
  scope :search_by_campus, ->(campus) { where(campus: campus) if campus.present? }

  # Class methods
  def self.search(params)
    courses = all
    
    # Apply filters
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      courses = courses.where("CAST(course_number AS TEXT) LIKE ? OR title LIKE ?", search_term, search_term)
    end
    courses = courses.by_level(params[:level].to_i) if params[:level].present? && params[:level] != 'all'
    courses = courses.search_by_term(params[:term]) if params[:term].present?
    courses = courses.search_by_campus(params[:campus]) if params[:campus].present?

    # Apply sorting
    case params[:sort]
    when 'number_asc'
      courses = courses.order(course_number: :asc)
    when 'number_desc'
      courses = courses.order(course_number: :desc)
    when 'title_asc'
      courses = courses.order(title: :asc)
    when 'title_desc'
      courses = courses.order(title: :desc)
    else
      courses = courses.order(course_number: :asc)
    end

    courses
  end
  
  def level
    course_number / 1000
  end
  
  # Helper methods for displaying formatted term and campus
  def formatted_term
    case term
    when "1252"
      "Spring 2025"
    when "1254"
      "Summer 2025"
    when "1258"
      "Autumn 2025"
    when "1242"
      "Spring 2024"
    when "1244"
      "Summer 2024"
    when "1248"
      "Autumn 2024"
    else
      term
    end
  end
  
  def formatted_campus
    case campus.downcase
    when "col"
      "Columbus"
    when "lma", "lim"
      "Lima"
    when "mns", "man"
      "Mansfield"
    when "mrn", "mar"
      "Marion"
    when "nwk", "new"
      "Newark"
    when "woo"
      "Wooster"
    else
      campus
    end
  end
end
