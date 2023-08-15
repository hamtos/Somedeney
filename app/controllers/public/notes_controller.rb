class Public::NotesController < ApplicationController
  def new
    @note = Note.new
    @lat = 35.625166
    @lng = 139.243611
    @tag_list = Tag.pluck(:name, :id)
  end

  def create
    @note = Note.new(note_params)
    @note.save

    redirect_to root_path
  end

  private

  def note_params
    params.require(:note).permit(:customer_id, :title, :body, :prefecture, :city, :latitude, :longitude)
  end
end
