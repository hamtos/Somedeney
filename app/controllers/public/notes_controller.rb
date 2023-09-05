class Public::NotesController < ApplicationController
  def new
    @note = Note.new
    @tags = Tag.with_notes_count
  end

  # 画像検索機能
  def detect_landmark_new
    @note = Note.new
    if params[:note].present?
      land_marks = Vision.get_image_data(note_params[:image])
      @land_mark_data = []
      if land_marks
        land_marks.each do |land_mark|
          lat = land_mark[2][0]["latLng"]["latitude"]
          lng = land_mark[2][0]["latLng"]["longitude"]
          score = land_mark[1]
          name = land_mark[0]
          add_data = {lat: lat, lng: lng, score: score, name: name}
          @land_mark_data.push(add_data)
        end
      else
        # flash[:error] = "みつかりませんでした"
      end
    end
    @tags = Tag.with_notes_count
    # @active_seach_tag = []
    @active_seach_tag = {text: "" , image: "active show"}
    render 'new'
  end

  def detect_landmark_edit
    @note = Note.find(params[:id])
    if params[:note].present?
      land_mark = Vision.get_image_data(note_params[:image])
      if land_mark
        @lat = land_mark[0][2][0]["latLng"]["latitude"]
        @lng = land_mark[0][2][0]["latLng"]["longitude"]
        @score = land_mark[0][1]
        @name = land_mark[0][0]
      else
        # flash[:error] = "みつかりませんでした"
      end
    end
    @tags = Tag.with_notes_count
    @my_tags = @note.tags
    @is_edit = true
    render "new"
  end

  def create
    Note.transaction do
      @note = Note.new(note_params)
      if @note.save
        update_tags(@note, params[:note]["selected_tags"])
        redirect_to note_path(@note)
      else
        flash[:error] = @note.errors.full_messages.join(', ')
        @note = Note.new
        @lat = 35.625166
        @lng = 139.243611
        @tag_list = Tag.pluck(:name, :id)
        render "new"
      end
    end
  end

  def show
    @note = Note.find(params[:id])
    @new_note = Note.new
  end

  def index
    # 自分の投稿は除く
    if customer_signed_in?
      @notes = Note.active.where(is_origin: true).where.not(customer_id: current_customer.id).order(created_at: :desc)
    else
      @notes = Note.active.where(is_origin: true).order(created_at: :desc)
    end

    # ワード検索データがあるときに絞り込み
    if params[:search]
      @search_word = params[:search]
      @notes = @notes.where("title LIKE :search OR prefecture LIKE :search OR city LIKE :search", search: "%#{@search_word}%")
    end

    # タグ検索用データがあるときに絞り込み
    if params[:tag_id]
      @search_word = "# #{Tag.find(params[:tag_id]).name}"
      @notes = @notes.joins(:note_tags).where(note_tags: {tag_id: params[:tag_id]})
    end

    # 都道府県検索用データがあるときに絞り込み
    if params[:prefecture_name]
      @search_word = "# #{params[:prefecture_name]}"
      @notes = @notes.where(prefecture: params[:prefecture_name])
    end

    # 市町村検索用データがあるときに絞り込み
    if params[:city_name]
      @search_word = "# #{params[:city_name]}"
      @notes = @notes.where(city: params[:city_name])
    end

    @tags = Tag.with_notes_count

    @is_note_index = true
  end

  def my_index
    # 自分の投稿を取得
    @notes = Note.active.where(customer_id: current_customer.id).order(created_at: :desc)

    # 検索データがあるときに絞り込み
    if params[:search]
      @search_word = params[:search]
      @notes = @notes.where("title LIKE :search OR prefecture LIKE :search OR city LIKE :search", search: "%#{@search_word}%")
    end

    # タグ検索用データがあるときに絞り込み
    if params[:tag_id]
      @search_word = "# #{Tag.find(params[:tag_id]).name}"
      @notes = @notes.joins(:note_tags).where(note_tags: {tag_id: params[:tag_id]})
    end

    # 都道府県検索用データがあるときに絞り込み
    if params[:prefecture_name]
      @search_word = "# #{params[:prefecture_name]}"
      @notes = @notes.where(prefecture: params[:prefecture_name])
    end

    # 市町村検索用データがあるときに絞り込み
    if params[:city_name]
      @search_word = "# #{params[:city_name]}"
      @notes = @notes.where(city: params[:city_name])
    end

    @is_note_my_index = true
  end

  def edit
    @note = Note.find(params[:id])
    if @note.latitude.present?
      @lat = @note.latitude
      @lng = @note.longitude
    else
      @lat = 35.625166
      @lng = 139.243611
    end

    @tags = Tag.with_notes_count
    @my_tags = @note.tags
    @is_edit = true
    render "new"
  end

  def update
    Note.transaction do
      @note = Note.find(params[:id])
      if @note.update(note_params)
        # タグの保存処理
        update_tags(@note, params[:note]["selected_tags"])

        # 処理の種類に応じてリダイレクト
        if params[:note]["delete_mode"]
          redirect_to notes_customers_path, notice: '投稿を削除しました'
        else
          redirect_to note_path(@note), notice: '投稿を更新しました'
        end
      else
        flash[:error] = "更新に失敗しました"
        redirect_back fallback_location: root_path
      end
    end
  end

  # noteコピー機能
  def copy_record
    source_record = Note.find(params[:note_id])
    new_record = Note.new
    new_record.customer_id = current_customer.id
    new_record.title = source_record.title
    new_record.body = source_record.body
    new_record.prefecture = source_record.prefecture
    new_record.city = source_record.city
    new_record.address = source_record.address
    new_record.latitude = source_record.latitude
    new_record.longitude = source_record.longitude
    if source_record.image.attached?
      new_record.image = source_record.image
    end
    if new_record.save
      # タグの複製
      tags_string = ""
      source_record.tags.each do |tag|
        tags_string += "#{tag.name},"
      end
      update_tags(new_record, tags_string)
      redirect_to note_path(new_record), notice: '投稿を複製しました'
    else
      flash[:alert] = '複製に失敗しました'
      render :show
    end
  end

  private

  def note_params
    params.require(:note).permit(:customer_id, :title, :body, :prefecture, :address, :city, :latitude, :longitude, :image, :is_deleted, :is_visited)
  end

  # タグの保存処理
  def update_tags(note, tags_string)
    unless tags_string.nil?
      note.note_tags.destroy_all
      tag_names = tags_string.split(",").map(&:strip) # tags_stringは","区切り文字列

        # 既存のタグの中で存在するものと、新たに作成するタグのリストを作成
      existing_tags = Tag.where(name: tag_names)
      new_tag_names = tag_names - existing_tags.pluck(:name)

        # 既存のタグをノートに紐付ける
      existing_tags.each do |tag|
        note.tags << tag
      end

        # 新たにタグを作成してノートに紐付ける
      new_tag_names.each do |tag_name|
        tag = Tag.create(name: tag_name)
        note.tags << tag
      end
    end
  end

  def test
  end
end
