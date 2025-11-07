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

ActiveRecord::Schema[7.2].define(version: 2025_11_07_110837) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "availabilities", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.integer "weekday", null: false
    t.time "start_time", null: false
    t.time "end_time", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id", "weekday"], name: "index_availabilities_on_employee_id_and_weekday", unique: true
    t.index ["employee_id"], name: "index_availabilities_on_employee_id"
  end

  create_table "employees", force: :cascade do |t|
    t.bigint "user_id"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "phone"
    t.string "email", null: false
    t.string "team"
    t.string "role"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_employees_on_email", unique: true
    t.index ["user_id"], name: "index_employees_on_user_id"
  end

  create_table "shift_assignments", force: :cascade do |t|
    t.bigint "shift_id", null: false
    t.bigint "employee_id", null: false
    t.bigint "created_by_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_shift_assignments_on_employee_id"
    t.index ["shift_id", "employee_id"], name: "index_shift_assignments_on_shift_id_and_employee_id", unique: true
    t.index ["shift_id"], name: "index_shift_assignments_on_shift_id"
  end

  create_table "shifts", force: :cascade do |t|
    t.string "title", null: false
    t.date "date", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.string "location"
    t.string "role_required"
    t.text "notes"
    t.integer "capacity", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_shifts_on_date"
  end

  create_table "swap_requests", force: :cascade do |t|
    t.bigint "shift_id", null: false
    t.bigint "from_employee_id", null: false
    t.bigint "to_employee_id", null: false
    t.integer "status", default: 0, null: false
    t.text "reason", null: false
    t.bigint "created_by_user_id", null: false
    t.bigint "decision_by_user_id"
    t.datetime "decided_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shift_id"], name: "index_swap_requests_on_shift_id"
    t.index ["status"], name: "index_swap_requests_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "full_name", null: false
    t.integer "role", default: 2, null: false
    t.string "jti", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "availabilities", "employees"
  add_foreign_key "employees", "users"
  add_foreign_key "shift_assignments", "employees"
  add_foreign_key "shift_assignments", "shifts"
  add_foreign_key "shift_assignments", "users", column: "created_by_user_id"
  add_foreign_key "swap_requests", "employees", column: "from_employee_id"
  add_foreign_key "swap_requests", "employees", column: "to_employee_id"
  add_foreign_key "swap_requests", "shifts"
  add_foreign_key "swap_requests", "users", column: "created_by_user_id"
  add_foreign_key "swap_requests", "users", column: "decision_by_user_id"
end
