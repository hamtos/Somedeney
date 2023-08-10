class Tag < ApplicationRecord

  has_many :note_tags, dependent: :destroy
  has_many :notes, through: :note_tags

  belongs_to :customer

  enum tag_category: {
    other: 0,
    nature: 1,
    history_culture: 2,
    structure: 3,
    gourmet: 4,
    agriculture: 5,
    facilities: 6,
    museum: 7,
    factory: 8,
    accommodation: 9,
    season: 10,
    certified: 11,
  }
end
