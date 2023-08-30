class Admin::NotesController < ApplicationController
  def index
    @notes = Note.all
  end

  def update
    @note = Note.find(params[:id])
    if @note.update(note_params)
      flash[:notice] = "ステータスを更新しました"
      redirect_to admin_notes_path
    else
      flash[:notice] = "ステータスの更新に失敗しました"
      redirect_to admin_notes_path
    end
  end

  private
  def note_params
    params.require(:note).permit(:is_deleted)
  end
end
