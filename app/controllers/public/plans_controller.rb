class Public::PlansController < ApplicationController
  def new
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
    @all_notes = Note.active.where(is_origin: true).order(created_at: :desc).limit(100)

    # 全体の投稿（左サイド）
    @selected_notes = []

    # 検索欄はlink_to
  end

  def add_note
    note_to_add = Note.find(params[:id])
    @selected_notes << note_to_add

    session[:selected_notes] ||= [] # セッションが初めて設定される場合に初期化
    session[:selected_notes] << note_to_add

    redirect_to new_plan_path
  end

  def index
  end
end
