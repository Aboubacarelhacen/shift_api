class CreateSwapRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :swap_requests do |t|
      t.references :shift, null: false, foreign_key: true
      t.bigint :from_employee_id, null: false
      t.bigint :to_employee_id, null: false
      t.integer :status, null: false, default: 0
      t.text :reason, null: false
      t.bigint :created_by_user_id, null: false
      t.bigint :decision_by_user_id
      t.datetime :decided_at

      t.timestamps
    end
    add_foreign_key :swap_requests, :employees, column: :from_employee_id
    add_foreign_key :swap_requests, :employees, column: :to_employee_id
    add_foreign_key :swap_requests, :users, column: :created_by_user_id
    add_foreign_key :swap_requests, :users, column: :decision_by_user_id
    add_index :swap_requests, :status
  end
end
