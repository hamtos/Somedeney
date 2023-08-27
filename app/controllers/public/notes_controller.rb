class Public::NotesController < ApplicationController
  def new
    @note = Note.new
    @lat = 35.625166
    @lng = 139.243611

    @tags = Tag.all
  end

  def create
    # noteモデル
    @note = Note.new(note_params)
    @note.tags = Tag.where(id: params[:note][:tag_id])
    if @note.save
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
