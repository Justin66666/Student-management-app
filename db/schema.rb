# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_04_18_193001) do
  create_table "applications", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "course_id", null: false
    t.integer "position_type"
    t.text "experience"
    t.string "programming_languages"
    t.integer "available_hours"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "section_id"
    t.index ["course_id"], name: "index_applications_on_course_id"
    t.index ["section_id"], name: "index_applications_on_section_id"
    t.index ["user_id"], name: "index_applications_on_user_id"
  end

  create_table "courses", force: :cascade do |t|
    t.integer "course_number"
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "term"
    t.string "campus"
    t.string "subject"
    t.string "catalog_number"
    t.string "course_id"
    t.string "section_number"
    t.string "component"
    t.string "class_number"
    t.text "prerequisites"
  end

  create_table "recommendation_letters", force: :cascade do |t|
    t.string "instructor_name"
    t.string "instructor_email"
    t.string "student_name"
    t.string "student_email"
    t.integer "course_id", null: false
    t.text "content"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_recommendation_letters_on_course_id"
  end

  create_table "recommendations", force: :cascade do |t|
    t.integer "instructor_id"
    t.string "student_email"
    t.integer "course_id"
    t.text "content"
    t.string "status"
    t.string "recommendation_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sections", force: :cascade do |t|
    t.string "number"
    t.string "instructor_name"
    t.string "schedule"
    t.string "location"
    t.integer "current_enrollment"
    t.integer "max_enrollment"
    t.integer "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "graders_required", default: 1, null: false
    t.index ["course_id"], name: "index_sections_on_course_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0
    t.boolean "approved", default: false, null: false
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.integer "invited_by_id"
    t.integer "invitations_count", default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "applications", "courses"
  add_foreign_key "applications", "sections"
  add_foreign_key "applications", "users"
  add_foreign_key "recommendation_letters", "courses"
  add_foreign_key "sections", "courses"
end
