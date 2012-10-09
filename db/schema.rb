# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121005080310) do

  create_table "answers", :force => true do |t|
    t.integer  "candidate_id"
    t.integer  "question_id"
    t.string   "answer"
    t.integer  "time_taken"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "candidates", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.text     "address"
    t.string   "phone1"
    t.string   "phone2"
    t.string   "technology"
    t.string   "certification"
    t.string   "skills"
    t.string   "resume_file_name"
    t.string   "resume_content_type"
    t.string   "resume_file_size"
    t.integer  "resume"
    t.integer  "schedule_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "categories", :force => true do |t|
    t.string   "category"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "complexities", :force => true do |t|
    t.string   "complexity"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "exams", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "created_by"
    t.string   "modified_by"
    t.integer  "no_of_question"
    t.integer  "total_time"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "complexity_id"
  end

  create_table "exams_instructions", :force => true do |t|
    t.integer "exam_id"
    t.integer "instruction_id"
  end

  create_table "exams_questions", :force => true do |t|
    t.integer "exam_id"
    t.integer "question_id"
  end

  create_table "experiences", :force => true do |t|
    t.integer  "candidate_id"
    t.date     "from_date"
    t.date     "to_date"
    t.string   "experience_in"
    t.string   "experience_from"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "instructions", :force => true do |t|
    t.string   "instruction"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "options", :force => true do |t|
    t.integer  "question_id"
    t.string   "option"
    t.boolean  "is_right"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "qualifications", :force => true do |t|
    t.integer  "candidate_id"
    t.string   "qualification_in"
    t.string   "qualification_from"
    t.date     "from_date"
    t.date     "to_date"
    t.float    "mark_percentage"
    t.string   "comments"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "questions", :force => true do |t|
    t.integer  "type_id"
    t.integer  "category_id"
    t.integer  "complexity_id"
    t.string   "answer_id"
    t.text     "question"
    t.integer  "allowed_time"
    t.string   "created_by"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "updated_by"
  end

  create_table "recruitment_tests", :force => true do |t|
    t.integer  "candidate_id"
    t.boolean  "is_completed"
    t.datetime "completed_on"
    t.integer  "right_answers"
    t.integer  "no_of_question_attended"
    t.float    "mark_percentage"
    t.string   "is_passed"
    t.string   "comments"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "roles", :force => true do |t|
    t.string   "role_name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "roles_users", :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  create_table "schedules", :force => true do |t|
    t.integer  "exam_id"
    t.datetime "sh_date"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "created_by"
    t.string   "updated_by"
  end

  create_table "templates", :force => true do |t|
    t.string   "name"
    t.text     "body"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "types", :force => true do |t|
    t.string   "question_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "user_email"
    t.string   "password"
    t.string   "salt"
    t.boolean  "isDelete"
    t.boolean  "isAlive"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "remember_token"
  end

  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end
