class Note < ApplicationRecord

  has_many :note_tags, dependent: :destroy
  has_many :tags, through: :note_tags

  has_many :note_plans, dependent: :destroy
  has_many :plans, through: :note_plans

  belongs_to :customer
  has_one_attached :image
end
