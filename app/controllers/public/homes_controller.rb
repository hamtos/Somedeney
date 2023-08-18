class Public::HomesController < ApplicationController

  def top
    # マップ
    if test = Note.where(customer_id: current_customer.id).order(updated_at: :desc).first
      @lat = test.latitude
      @lng = test.longitude
    end
    @marker_lats = Note.where.not(latitude: nil).pluck(:latitude)
    @marker_lngs = Note.where.not(latitude: nil).pluck(:longitude)
    @marker_titles = Note.where.not(latitude: nil).pluck(:title)

    # 全体の投稿（右サイド）
    @notes = Note.all.limit(10)
  end
end
