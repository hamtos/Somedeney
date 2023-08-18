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
  end

  private

  def note_params
    params.require(:note).permit(:customer_id, :title, :body, :prefecture, :address, :city, :latitude, :longitude, :image)
  end
end
