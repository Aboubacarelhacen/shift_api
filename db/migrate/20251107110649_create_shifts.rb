class CreateShifts < ActiveRecord::Migration[7.2]
  def change
    create_table :shifts do |t|
      t.string :title, null: false
      t.date :date, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.string :location
      t.string :role_required
      t.text :notes
      t.integer :capacity, null: false, default: 1

      t.timestamps
    end
    add_index :shifts, [:date]
  end
end
