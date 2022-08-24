require 'net/http'
class V1::ShoplistController < ApplicationController
  before_action :authenticate_v1_user!
  def get
    if !Base.exists?(user_id: current_user.id)
      # 住所が未登録の場合
      result = { succes: false , redirect: "userbase",data:{uid:current_user.id} }
    else
      # 登録している場合
      @base = Base.find_by(user_id: current_user.id)
      if @base.lat.blank? || @base.lng.blank?
        # 住所がおかしい場合
        result = { succes: false , redirect: "userbase",data:{uid:current_user.id} }
      else
        # 住所があってる場合
          # PLACE API のURI
          uri = URI.parse("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{@base.lat},#{@base.lng}&radius=500&types=restaurant&language=ja&key=#{Constants::GOOGLE_API_KEY}")
          @query = uri.query
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
          @shops = []
          @place_num = 0
          while !@google_res["results"][ @place_num ].blank?
            @temp = {"shop-name"    => @google_res["results"][@place_num]["name"],
                    "shop-address" => @google_res["results"][0]["vicinity"],
                    "shop-lat"     => @google_res["results"][0]["geometry"]["location"]["lat"],
                    "shop-lng"     => @google_res["results"][0]["geometry"]["location"]["lng"],
                    "place-id"     => @google_res["results"][0]["place_id"]}
            @shops[@place_num] = @temp

            @place_num += 1
          end
           puts @shops.to_json
          result = { succes: true,data:@shops.as_json, uid:current_user.id,total:@place_num,sort:0 }
                    #result = { succes: false, data:{uid:current_user.id} }
      end
    end
    render json: result
  end
end
