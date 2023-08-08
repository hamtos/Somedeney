class Tag < ApplicationRecord

  has_many :note_tags, dependent: :destroy
  has_many :notes, through: :note_tags

  belongs_to :customer

  enum category: {
    other: 0,
    natural: 1,
    history_culture: 2,
    gourmet: 3,
    hot_spring: 4,
    facilities: 5,
    mitinoeki: 6,
    month: 7,
    seasonal: 8,
  }
end
