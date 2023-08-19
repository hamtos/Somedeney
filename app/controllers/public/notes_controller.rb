class Public::NotesController < ApplicationController
  def new
    @note = Note.new
    @lat = 35.625166
    @lng = 139.243611
    @tag_list = Tag.pluck(:name, :id)
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
