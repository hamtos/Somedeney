class Plan < ApplicationRecord
  belongs_to :customer

  has_many :note_plans, dependent: :destroy
  has_many :notes, through: :note_plans

  # 日付から曜日を取得
  def get_day_of_week(datetime)
    days_of_week = %w(日 月 火 水 木 金 土)
    day_of_week_index = datetime.wday
    days_of_week[day_of_week_index]
  end
end
