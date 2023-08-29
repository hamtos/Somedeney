class Public::HomesController < ApplicationController

  def top
    # マップ
    @lat = 35.625166
    @lng = 139.243611

    if customer_signed_in?
      if latlng = Note.active.where(customer_id: current_customer.id).order(updated_at: :desc).first
        @lat = latlng.latitude
        @lng = latlng.longitude
      end
    end

    if params[:latitude]
      @lat = params[:latitude]
      @lng = params[:longitude]
    end

    @test_name = Geocoder.search([@lat, @lng]).first.state

    @marker_lats = Note.active.where.not(latitude: nil).pluck(:latitude)
    @marker_lngs = Note.active.where.not(latitude: nil).pluck(:longitude)
    @marker_titles = Note.active.where.not(latitude: nil).pluck(:title)

    # 全体の投稿（右サイド）
    if customer_signed_in?
      @near_notes = Note.active.where(is_origin: true).where.not(customer_id: current_customer.id).near([@lat, @lng], 100)
      @all_notes = Note.active.where(is_origin: true).where.not(customer_id: current_customer.id).order(updated_at: :desc)
    else
      @near_notes = Note.active.where(is_origin: true).near([@lat, @lng], 100)
      @all_notes = Note.active.where(is_origin: true).order(updated_at: :desc)
    end

    # タグ検索用データがあるときに絞り込み
    if params[:tag_id]
      @search_word = "# #{Tag.find(params[:tag_id]).name}"
      @near_notes = @near_notes.joins(:note_tags).where(note_tags: {tag_id: params[:tag_id]})
      @all_notes = @all_notes.joins(:note_tags).where(note_tags: {tag_id: params[:tag_id]})
    end

    # 投稿の表示数制限
    @near_notes = @near_notes.limit(100)
    @all_notes = @all_notes.limit(100)


    # 全体の投稿（左サイド）
    if customer_signed_in?
      @my_notes = Note.active.where(customer_id: current_customer.id).order(created_at: :desc).limit(100)
    end

    # 検索フォーム
    @note = Note.new

    # cardのリンク設定用
    @is_top = true
  end
end
