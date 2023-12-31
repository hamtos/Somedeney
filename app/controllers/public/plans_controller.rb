class Public::PlansController < ApplicationController
  def new
    # マップ
    @lat = 35.625166
    @lng = 139.243611

    if customer_signed_in?
      if latlng = Note.active.where(customer_id: current_customer.id).order(updated_at: :desc).first
        @lat = latlng.latitude
        @lng = latlng.longitude
      end
    end

    # 全体の投稿（右サイド）
    @my_notes = Note.active.where(is_origin: true).where(customer_id: current_customer.id).order(created_at: :desc)
    @another_notes = Note.active.where(is_origin: true).where.not(customer_id: current_customer.id).order(created_at: :desc).limit(100)

    # 検索ワードがあるとき絞り込み
    if params[:search]
      @search_word = params[:search]
      @my_notes = @my_notes.where("title LIKE :search OR prefecture LIKE :search OR city LIKE :search", search: "%#{@search_word}%")
      @another_notes = @another_notes.where("title LIKE :search OR prefecture LIKE :search OR city LIKE :search", search: "%#{@search_word}%")
    end

    # 表示件数を指定
    @my_notes = @my_notes.limit(100)
    @another_notes = @another_notes.limit(100)

    # 選択済の投稿（左サイド）
    note_ids = session[:selected_notes_id] || []
    @selected_notes = Note.where(id: note_ids).sort_by { |id| -note_ids.index(id[:id]) }

    @marker_data = Note.where(id: note_ids).where.not(latitude: nil) # マップに表示するマーカーの一覧
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
    # 画面遷移時のエラー処理
    if session[:selected_notes_id] == []
      flash[:error] = "スポット一つ以上選択してください"
      redirect_to new_plan_path
    end

    @plan = Plan.new

    note_ids = session[:selected_notes_id] || []
    @notes = Note.where(id: note_ids).sort_by { |id| note_ids.index(id[:id]) }
  end

  def up_note
    note_ids = session[:selected_notes_id] || []
    id_to_move = params[:id].to_i
    index = note_ids.index(id_to_move)
    if  index > 0
      note_ids[index], note_ids[index - 1] = note_ids[index - 1], note_ids[index]
      session[:selected_notes_id] = note_ids
    end
    redirect_to plans_confirm_path
  end

  def down_note
    note_ids = session[:selected_notes_id] || []
    id_to_move = params[:id].to_i
    index = note_ids.index(id_to_move)
    if  index < (note_ids.length - 1)
      note_ids[index], note_ids[index + 1] = note_ids[index + 1], note_ids[index]
      session[:selected_notes_id] = note_ids
    end
    redirect_to plans_confirm_path
  end

  def create
    note_ids = session[:selected_notes_id]

    Plan.transaction do
      plan = Plan.new(plan_params)
      if plan.save
        note_ids.each_with_index do |note_id, index|
          order = index + 1
          departure = params[:plan]["note_#{index}_departure"]
          arrival = params[:plan]["note_#{index}_arrival"]
          comment = params[:plan]["note_#{index}_comment"]
          plan.note_plans.create!(note_id: note_id, order: order, departure: departure, arrival: arrival, comment: comment)
        end
        session[:selected_notes_id] = []
        flash[:notice] = '新しい計画を作成しました'
        redirect_to plan_path(plan)
      else
        flash[:error] = '保存できませんでした'
        render "confirm"
      end
    end
  end

  def show
    @plan = Plan.find(params[:id])
  end

  def index
    @plans = Plan.where(customer_id: current_customer.id)

    # 検索データがあるときに絞り込み
    if params[:search]
      search_word = params[:search]
      @plans = @plans.joins(:notes).where(
        "plans.name LIKE ? OR notes.title LIKE ? OR notes.prefecture LIKE ?",
        "%#{search_word}%",
        "%#{search_word}%",
        "%#{search_word}%"
      ).distinct
    end
  end

  def edit
    @plan = Plan.find(params[:id])
    session[:selected_notes_id] = @plan.notes.pluck(:id)
    note_ids = session[:selected_notes_id] || []
    @notes = Note.where(id: note_ids).sort_by { |id| note_ids.index(id[:id]) }
    @is_edit = true
    render "confirm"
  end

  def edit_new
    @plan = Plan.find(params[:id])
    note = @plan.notes.first
    @lat = note.latitude
    @lng = note.longitude

    @marker_lats = Note.active.where.not(latitude: nil).pluck(:latitude)
    @marker_lngs = Note.active.where.not(latitude: nil).pluck(:longitude)
    @marker_titles = Note.active.where.not(latitude: nil).pluck(:title)

    # 全体の投稿（右サイド）
    @all_notes = Note.active.where(is_origin: true).order(created_at: :desc).limit(100)

    # 全体の投稿（左サイド）
    note_ids = session[:selected_notes_id] || []
    @selected_notes = Note.where(id: note_ids).sort_by { |id| -note_ids.index(id[:id]) }

    @is_edit = true
    render "new"
  end

  def edit_confirm
    # 画面遷移時のエラー処理
    if session[:selected_notes_id] == []
      flash[:error] = "スポット一つ以上選択してください"
      redirect_to new_plan_path
    end

    @plan = Plan.find(params[:id])

    note_ids = session[:selected_notes_id] || []
    @notes = Note.where(id: note_ids).sort_by { |id| note_ids.index(id[:id]) }

    @is_edit = true
    render "confirm"
  end

  def update
    plan = Plan.find(params[:id])
    if plan.update(plan_params)
      # plan_noteを再作成
      plan.note_plans.destroy_all

      note_ids = session[:selected_notes_id]
      note_ids.each_with_index do |note_id, index|
        order = index + 1
        departure = params[:plan]["note_#{index}_departure"]
        arrival = params[:plan]["note_#{index}_arrival"]
        comment = params[:plan]["note_#{index}_comment"]
        plan.note_plans.create!(note_id: note_id, order: order, departure: departure, arrival: arrival, comment: comment)
      end
      session[:selected_notes_id] = []
      flash[:notice] = '計画を更新しました'
      redirect_to plan_path(plan)
    end
  end

  def destroy
    plan = Plan.find(params[:id])
    plan.destroy
    flash[:notice] = "計画を削除しました"
    redirect_to plans_path
  end

  def plan_params
    params.require(:plan).permit(:customer_id, :name, :is_complete)
  end
end
