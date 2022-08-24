require 'net/http'
class V1::ShoplistController < ApplicationController
  before_action :authenticate_v1_user!

  def get # shop list を取得

    if !Base.exists?(user_id: current_user.id)
      # 住所が未登録の場合
      render json: { "succes": false, "redirect": "userbase", "data": { "uid": current_user.id} }
      return
    end
    
    # 住所取得
    @base = Base.find_by(user_id: current_user.id)

    if @base.lat.blank? || @base.lng.blank?
        # 住所がおかしい場合
        render json: { "succes": false , "redirect": "userbase", "data": { "uid": current_user.id} }
        return
    end
 
    # PLACE API のURI
    uri = URI.parse("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{@base.lat},#{@base.lng}&radius=500&types=restaurant&language=ja&key=#{Constants::GOOGLE_API_KEY}")
    @query = uri.query

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
    @google_res = JSON.parse(response.body)
    @shops = []
    @place_num = 0

    # お店一覧をjson形式にする
    while !@google_res["results"][ @place_num ].blank?
      @shops[@place_num] = {    "shop-name" => @google_res["results"][@place_num]["name"],
                             "shop-address" => @google_res["results"][@place_num]["vicinity"],
                                 "shop-lat" => @google_res["results"][@place_num]["geometry"]["location"]["lat"],
                                 "shop-lng" => @google_res["results"][@place_num]["geometry"]["location"]["lng"],
                                 "place-id" => @google_res["results"][@place_num]["place_id"]
                            }
              
      #Shopがデータベースに存在しなかったらデータベースに保存
      if !Shop.exists?(place_id: @google_res["results"][@place_num]["place_id"])
        shop = Shop.new(      place_id: @google_res["results"][@place_num]["place_id"],
                             shop_name: @google_res["results"][@place_num]["name"],
                          shop_address: @google_res["results"][ @place_num ]["vicinity"],
                                   lat: @google_res["results"][ @place_num ]["geometry"]["location"]["lat"],
                                   lng: @google_res["results"][ @place_num ]["geometry"]["location"]["lng"]
                        )

        if shop.save
          # @memo_exists.push("保存しました")
        else
          # @memo_exists.push("保存失敗")
        end
      end

      # Memoがデータベースに存在しなかったら作成、保存
      if !Memo.exists?(user_id: current_user.id, place_id: @google_res["results"][@place_num]["place_id"])
        memo = Memo.new(  user_id: current_user.id, 
                         place_id: @google_res["results"][ @place_num ]["place_id"],
                             memo: "",
                            count: 0,
                          favorite: 0
                        )
        if memo.save
        else
        end
      end

      @place_num += 1
    end
    render json: { "succes": true,
                     "data": {
                                 uid: current_user.id,
                               total: @place_num,
                                sort: 0,
                                shop: @shops.as_json
                              }
                  }

  end
end
