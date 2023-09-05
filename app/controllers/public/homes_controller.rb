class Public::HomesController < ApplicationController

  def top
    # マップ
    @lat = 35.625166
    @lng = 139.243611

    if customer_signed_in?
      if latlng = Note.active.where(customer_id: current_customer.id).where.not(latitude: nil).order(updated_at: :desc).first
        @lat = latlng.latitude
        @lng = latlng.longitude
      end
    end

    if params[:latitude]
      @lat = params[:latitude]
      @lng = params[:longitude]
    end

    origin_notes = Note.active.where(is_origin: true)

    # 全体の投稿（右サイド）
    if customer_signed_in?
      @near_notes = origin_notes.where.not(customer_id: current_customer.id).near([@lat, @lng], 100)
    else
      @near_notes = origin_notes.near([@lat, @lng], 100)
    end

    @all_notes = origin_notes.order(updated_at: :desc)

    # タグ検索用データがあるときに絞り込み
    if params[:tag_id]
      @search_word = "# #{Tag.find(params[:tag_id]).name}"
      @near_notes = @near_notes.joins(:note_tags).where(note_tags: {tag_id: params[:tag_id]})
      @all_notes = @all_notes.joins(:note_tags).where(note_tags: {tag_id: params[:tag_id]})
    end

    # 都道府県検索用データがあるときに絞り込み
    if params[:prefecture_name]
      @search_word = "# #{params[:prefecture_name]}"
      @near_notes = @near_notes.where(prefecture: params[:prefecture_name])
      @all_notes = @all_notes.where(prefecture: params[:prefecture_name])
    end

    # 市町村検索用データがあるときに絞り込み
    if params[:city_name]
      @search_word = "# #{params[:city_name]}"
      @near_notes = @near_notes.where(city: params[:city_name])
      @all_notes = @all_notes.where(city: params[:city_name])
    end

    # 投稿の表示数制限
    @near_notes = @near_notes.limit(100)
    @all_notes = @all_notes.limit(100)
    @marker_data = @all_notes.where.not(latitude: nil) # マップに表示するマーカーの一覧

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
