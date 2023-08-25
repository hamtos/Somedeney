class Plan < ApplicationRecord
  belongs_to :customer

  has_many :note_plans, dependent: :destroy
  has_many :notes, through: :note_plans
end
