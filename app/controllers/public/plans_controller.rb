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
    note_ids = session[:selected_notes_id] || []
    @selected_notes = Note.where(id: note_ids)

    # 検索欄はlink_to
  end

  def add_note
    session[:selected_notes_id] ||= [] # セッションが初めて設定される場合に初期化
    session[:selected_notes_id] << params[:id].to_i

    redirect_to new_plan_path
  end

  def remove_note
    session[:selected_notes_id] ||= [] # セッションが初めて設定される場合に初期化
    session[:selected_notes_id].delete(params[:id].to_i)

    redirect_to new_plan_path
  end

  def reset_note
    session[:selected_notes_id].clear
    redirect_to new_plan_path
  end

  def confirm
  end

  def index
  end
end
