class Tag < ApplicationRecord

  has_many :note_tags, dependent: :destroy
  has_many :notes, through: :note_tags

  # note_countカラムを付与する
  def self.with_notes_count
    joins(:notes)
   .select('tags.*, COUNT(notes.id) as note_count')
   .group('tags.id')
   .order('note_count DESC')
  end
end
