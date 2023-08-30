class Note < ApplicationRecord

  has_many :note_tags, dependent: :destroy
  has_many :tags, through: :note_tags

  has_many :note_plans, dependent: :destroy
  has_many :plans, through: :note_plans

  belongs_to :customer
  has_one_attached :image

  geocoded_by :address
  after_validation :geocode

  reverse_geocoded_by :latitude, :longitude
  after_validation :reverse_geocode

  # 削除されていないデータ
  scope :active, -> { joins(:customer).where(is_deleted: false, customers: { is_deleted: false }) }

  # 画像表示メソッド
  def get_image(width, height)
    image.variant(resize_to_limit: [width, height]).processed
  end
end
