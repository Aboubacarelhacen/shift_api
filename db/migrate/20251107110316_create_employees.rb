class CreateEmployees < ActiveRecord::Migration[7.2]
  def change
    create_table :employees do |t|
      t.references :user, null: true, foreign_key: true
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :phone
      t.string :email, null: false
      t.string :team
      t.string :role
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :employees, :email, unique: true
  end
end
