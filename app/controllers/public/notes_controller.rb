class Public::NotesController < ApplicationController
  def new
    @note = Note.new
    @lat = 35.625166
    @lng = 139.243611

    @tags = Tag.joins(:notes)
               .select('tags.*, COUNT(notes.id) as note_count')
               .group('tags.id')
               .order('note_count DESC')
  end

  def create
    Note.transaction do
      @note = Note.new(note_params)
      if @note.save
        # タグの保存処理
        tags_string = params[:note]["selected_tags"]
        tag_names = tags_string.split(",").map(&:strip) # tags_stringは","区切り文字列

        # 既存のタグの中で存在するものと、新たに作成するタグのリストを作成
        existing_tags = Tag.where(name: tag_names)
        new_tag_names = tag_names - existing_tags.pluck(:name)

        # 既存のタグをノートに紐付ける
        existing_tags.each do |tag|
          @note.tags << tag
        end

        # 新たにタグを作成してノートに紐付ける
        new_tag_names.each do |tag_name|
          tag = Tag.create(name: tag_name)
          @note.tags << tag
        end

        redirect_to root_path
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

    # 検査データがあるときに絞り込み
    if params[:search]
      @search_word = params[:search]
      @notes = @notes.where("title LIKE :search OR prefecture LIKE :search OR city LIKE :search", search: "%#{@search_word}%")
    end
  end

  def my_index
    # 自分の投稿を取得
    @notes = Note.active.where(customer_id: current_customer.id).order(created_at: :desc)

    # 検査データがあるときに絞り込み
    if params[:search]
      @search_word = params[:search]
      @notes = @notes.where("title LIKE :search OR prefecture LIKE :search OR city LIKE :search", search: "%#{@search_word}%")
    end
  end

  def edit
    @note = Note.find(params[:id])
  end

  def update
    @note = Note.find(params[:id])
    if @note.update(note_params)
      redirect_to notes_customers_path
    else
      redirect_back fallback_location: root_path
    end
  end

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
      redirect_to note_path(new_record), notice: '投稿を複製しました'
    else
      flash[:alert] = '複製に失敗しました'
      render :show
    end
  end

  private

  def note_params
    params.require(:note).permit(:customer_id, :title, :body, :prefecture, :address, :city, :latitude, :longitude, :image, :is_deleted)
  end
end
