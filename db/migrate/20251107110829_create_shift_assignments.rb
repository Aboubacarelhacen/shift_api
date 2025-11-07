class CreateShiftAssignments < ActiveRecord::Migration[7.2]
  def change
    create_table :shift_assignments do |t|
      t.references :shift, null: false, foreign_key: true
      t.references :employee, null: false, foreign_key: true
      t.bigint :created_by_user_id, null: false

      t.timestamps
    end
    add_index :shift_assignments, [:shift_id, :employee_id], unique: true
    add_foreign_key :shift_assignments, :users, column: :created_by_user_id
  end
end
