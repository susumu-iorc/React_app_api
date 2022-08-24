require 'net/http'
class V1::UserbaseController < ApplicationController
  before_action :authenticate_v1_user!

  def check
    if Base.exists?(user_id: current_user.id)
      render json: { succes: true , data:{uid:current_user.id} }
    else
      render json: { succes: false, data:{uid:current_user.id} }
    end
  end

  def get
    if Base.exists?(user_id: current_user.id)
      @base = Base.find_by(user_id:current_user.id)
      render json: { succes: true , data:{uid:            current_user.id,
                                          "user-post_code": @base.user_post_code,
                                          "user-pref":      @base.user_pref,
                                          "user-city":      @base.user_city,
                                          "user-area":      @base.user_area,
                                          "user-lat":       @base.lat,
                                          "user-lng":       @base.lng} }
    else
      render json: { succes: false, data:{uid:current_user.id} }
    end
  end

  def update
    post_body = JSON.parse(request.body.read)

    @full_address = "#{post_body["user_pref"]}#{post_body["user_city"]}#{post_body["user_area"]}" 
    @full_address = URI.encode_www_form_component(@full_address)
    uri = URI.parse("https://maps.googleapis.com/maps/api/geocode/json?new_forward_geocoder=true&address=#{@full_address}&key=#{Constants::GOOGLE_API_KEY}")

    

    # データ取得
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    # httpsのサイトに送るときは要記述
    http.use_ssl = true
    # リクエストを送る
    response = http.request(request)
    # レスポンスの確認
    logger.debug response.code
    logger.debug response.body

    @google_res = JSON.parse(response.body)

    @user_lat = @google_res["results"][0]["geometry"]["location"]["lat"]
    @user_lng = @google_res["results"][0]["geometry"]["location"]["lng"]

    result_data = {user_id:current_user.id,
                   "user-post_code": params["user_post_code"],
                   "user-pref":      params["user_pref"],
                   "user-city":      params["user_city"],
                   "user-area":      params["user_area"],
                   "user-lat":            @user_lat,
                   "user-lng":            @user_lng }
    # 保存処理
    if @user_lat.blank? || @user_lng.blank?
      # 緯度経度が正しく取得できなかった場合の処理
      result = {success: false, message: "データが不正"}
    else
      # 緯度経度が正しい場合の処理
      if Base.exists?(user_id: current_user.id)
        # すでにある住所から更新処理
        @base = Base.find_by(user_id:current_user.id)
        if @base.update( user_id:current_user.id,
                         user_post_code: params["user_post_code"],
                         user_pref:      params["user_pref"],
                         user_city:      params["user_city"],
                         user_area:      params["user_area"],
                         lat:            @user_lat,
                         lng:            @user_lng )
          # update が成功した
          result = {success: true, message: "住所更新完了",data:result_data}
        else
          result = {success: false, message: "住所更新失敗"}
        end
      else
        # 住所の初回登録
        @base = Base.new( user_id:current_user.id,user_post_code: params["user_post_code"],
                          user_pref:      params["user_pref"],
                          user_city:      params["user_city"],
                          user_area:      params["user_area"],
                          lat:            @user_lat,
                          lng:            @user_lng )
        if @base.save
          # 初回登録できた
          result = {success: true, message: "住所登録成功",data:result_data}
        else
          result = {success: false, message: "住所登録失敗"}
        end
      end
    end
    

    render json: result
  end
end
