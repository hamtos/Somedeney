class Public::HomesController < ApplicationController

  def top
    @lat = 35.625166
    @lng = 139.243611
    @marker_lats = Note.pluck(:latitude)
    @marker_lngs = Note.pluck(:longitude)
    @marker_titles = Note.pluck(:title)
  end
end
