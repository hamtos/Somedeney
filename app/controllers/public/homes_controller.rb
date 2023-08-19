class Public::HomesController < ApplicationController

  def top
    # マップ
    if customer_signed_in?
      if test = Note.active.where(customer_id: current_customer.id).order(updated_at: :desc).first
        @lat = test.latitude
        @lng = test.longitude
      end
    end
    @marker_lats = Note.active.where.not(latitude: nil).pluck(:latitude)
    @marker_lngs = Note.active.where.not(latitude: nil).pluck(:longitude)
    @marker_titles = Note.active.where.not(latitude: nil).pluck(:title)

    # 全体の投稿（右サイド）
    if customer_signed_in?
      @another_notes = Note.active.where.not(customer_id: current_customer.id, is_origin: true).order(created_at: :desc).page(params[:page]).per(10)
    else
      @another_notes = Note.active.where.not(is_origin: true).order(created_at: :desc).page(params[:page]).per(10)
    end

    # 全体の投稿（左サイド）
    if customer_signed_in?
      @my_notes = Note.active.where(customer_id: current_customer.id).order(created_at: :desc).page(params[:page]).per(10)
    end

    # 検索フォーム
    @note = Note.new
  end
end
