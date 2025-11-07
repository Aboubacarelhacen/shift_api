class CreateAvailabilities < ActiveRecord::Migration[7.2]
  def change
    create_table :availabilities do |t|
      t.references :employee, null: false, foreign_key: true
      t.integer :weekday, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false

      t.timestamps
    end
    add_index :availabilities, [:employee_id, :weekday], unique: true
  end
end
