class Employee < ApplicationRecord
  belongs_to :user, optional: true

  has_many :availabilities, dependent: :destroy
  has_many :shift_assignments, dependent: :destroy
  has_many :shifts, through: :shift_assignments

  validates :first_name, :last_name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :active, inclusion: { in: [true, false] }

  def full_name
    "#{first_name} #{last_name}".strip
  end
end
