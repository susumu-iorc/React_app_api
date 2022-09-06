require 'net/http'
class V1::UserbaseController < ApplicationController
  before_action :authenticate_v1_user!

  def check # ユーザーの住所が登録されているかどうかの確認
    if Base.exists?(user_id: current_user.id)
      render json: { "success":  true, "data": {"uid": current_user.id} }
    else
      render json: { "success": false, "data": {"uid": current_user.id} }
    end
  end

  def get # 登録されているユーザーの住所取得
    if Base.exists?(user_id: current_user.id)
      @base = Base.find_by(user_id:current_user.id)
      render json: { "success": true,
                       "data": {
                                            "uid": current_user.id,
                                 "user-post_code": @base.user_post_code,
                                      "user-pref": @base.user_pref,
                                      "user-city": @base.user_city,
                                      "user-area": @base.user_area,
                                       "user-lat": @base.lat,
                                       "user-lng": @base.lng
                                }
                    }
    else
      render json: { "success": false, "data": { "uid": current_user.id} }
    end
  end

  def update # ユーザーの住所登録
    # postが送られてきているかどうか
    if request.body.read.blank?
      render json: { "success": false, "message": "データが正常にpostされませんでした"}
      return
    end

    # postされたデータ取り出し
    post_body = JSON.parse(request.body.read)
 
    # ユーザーの住所組み立て → URLエンコード
    @full_address = "#{post_body["user-pref"]}#{post_body["user-city"]}#{post_body["user-area"]}" 
    @full_address = URI.encode_www_form_component(@full_address)
 
    # google map api のURL作成
    uri = URI.parse("https://maps.googleapis.com/maps/api/geocode/json?new_forward_geocoder=true&address=#{@full_address}&key=#{Constants::GOOGLE_API_KEY}")

    # データ取得
    http    = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    # httpsのサイトに送るときは要記述
    http.use_ssl = true
    # リクエストを送る
    response = http.request(request)
    # レスポンスの確認
    logger.debug response.code
    logger.debug response.body
    # 内容取得
    @google_res = JSON.parse(response.body)

    @user_lat = @google_res["results"][0]["geometry"]["location"]["lat"]
    @user_lng = @google_res["results"][0]["geometry"]["location"]["lng"]

    result_data = {           "uid": current_user.id,
                   "user-post_code": post_body["user-post-code"],
                        "user-pref": post_body["user-pref"],
                        "user-city": post_body["user-city"],
                        "user-area": post_body["user-area"],
                         "user-lat": @user_lat,
                         "user-lng": @user_lng
                   }

    # 保存処理
    if @user_lat.blank? || @user_lng.blank?
      # 緯度経度が正しく取得できなかった場合の処理
      render json: {"success": false, "message": "データが不正"}
      return
    end

    # 緯度経度が正しい場合の処理
    if Base.exists?(user_id: current_user.id)
      # すでにある住所から更新処理
      @base = Base.find_by(user_id:current_user.id)
      if @base.update(
                              user_id: current_user.id,
                       user_post_code: post_body["user-post-code"],
                            user_pref: post_body["user-pref"],
                            user_city: post_body["user-city"],
                            user_area: post_body["user-area"],
                                  lat: @user_lat,
                                  lng: @user_lng 
                      )
        # distanceモデルを削除
        Distance.where(user_id: current_user.id).delete_all
        # update が成功した
        render json: { "success":  true, "message": "住所更新完了", "data": result_data}
        return
      else
        # update が失敗した
        render json: { "success": false, "message": "住所更新失敗"}
        return
      end

    else
      
      # 住所の初回登録
      puts current_user.id
      puts post_body["user-post-code"]
      puts post_body["user-pref"]
      puts post_body["user-city"]
      puts   post_body["user-area"]
      puts @user_lat
      puts @user_lng
      @base = Base.new(
                              user_id: current_user.id,
                       user_post_code: post_body["user-post-code"],
                            user_pref: post_body["user-pref"],
                            user_city: post_body["user-city"],
                            user_area: post_body["user-area"],
                                  lat: @user_lat,
                                  lng: @user_lng
                       )
      if @base.save
        # 初回登録できた
        render json: { "success":  true, "message": "住所登録成功", "data": result_data}
      else
        # 初回登録失敗
        render json: { "success": false, "message": "住所登録失敗"}
      end
    end
  end

end
