require 'net/http'
class V1::ShoplistController < ApplicationController
  before_action :authenticate_v1_user!
  
  def get_googlemap_list(__lat, __lng, __APIKEY, __next_page_token = "") # googlemapからshopリスト取得
        # PLACE API のURI

        uri = URI.parse("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{__lat},#{__lng}&radius=500&types=restaurant&language=ja&key=#{__APIKEY}&pagetoken=#{__next_page_token}")

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
        return JSON.parse(response.body)
  end

  def sort_shops(__shops, __sort, __total) # shopのソート
    case __sort
    when 2
      favo_3 = []
      favo_2 = []
      favo_1 = []
      favo_0 = []
      num = 0
      result = []
      puts "test-------------------------------------"
      while num < __total
       memo = Memo.find_by( place_id: __shops[num]["place-id"], user_id: current_user.id)
        case memo.favorite
        when 3
          favo_3.push(__shops[num])
        when 2
          favo_2.push(__shops[num])
        when 1
          favo_1.push(__shops[num])
        when 0
          favo_0.push(__shops[num])
        end
        
       num += 1
      end
      for tmp_shop in favo_3
        result.push(tmp_shop)
      end
      for tmp_shop in favo_2
        result.push(tmp_shop)
      end
      for tmp_shop in favo_1
        result.push(tmp_shop)
      end
      for tmp_shop in favo_0
        result.push(tmp_shop)
      end
    when 1
    else
    end
    return result
  end
  def get # shop list を取得
    # postが送られてきているかどうか
    post_sort = 0
    if !request.body.read.blank?
      post_body = JSON.parse(request.body.read)
      if post_body["sort"] == 1 || post_body["sort"] == 2
        post_sort = post_body["sort"] 
      end 
    end

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


    @google_res = []
    @google_res[0] = get_googlemap_list(@base.lat,@base.lng,Constants::GOOGLE_API_KEY)
    @shop_list_count = 0

    while @shop_list_count < 5 && !@google_res[@shop_list_count]["next_page_token"].blank?
      @google_res[@shop_list_count + 1] = get_googlemap_list(@base.lat,@base.lng,Constants::GOOGLE_API_KEY,@google_res[@shop_list_count]["next_page_token"])
      if !@google_res[@shop_list_count + 1].blank? 
        @shop_list_count += 1
      end
    end


    @shops = []
    @res_num = 0
    @total   = 0

    while @res_num <= @shop_list_count
      @place_num = 0
      # お店一覧をjson形式にする
      while !@google_res[@res_num]["results"][ @place_num ].blank?
        @shops[@total] = {        "shop-name" => @google_res[@res_num]["results"][@place_num]["name"],
                               "shop-address" => @google_res[@res_num]["results"][@place_num]["vicinity"],
                                   "shop-lat" => @google_res[@res_num]["results"][@place_num]["geometry"]["location"]["lat"],
                                   "shop-lng" => @google_res[@res_num]["results"][@place_num]["geometry"]["location"]["lng"],
                                   "place-id" => @google_res[@res_num]["results"][@place_num]["place_id"]
                          }
              
        #Shopがデータベースに存在しなかったらデータベースに保存
        if !Shop.exists?(place_id: @google_res[@res_num]["results"][@place_num]["place_id"])
          shop = Shop.new(      place_id: @google_res[@res_num]["results"][@place_num]["place_id"],
                               shop_name: @google_res[@res_num]["results"][@place_num]["name"],
                            shop_address: @google_res[@res_num]["results"][ @place_num ]["vicinity"],
                                     lat: @google_res[@res_num]["results"][ @place_num ]["geometry"]["location"]["lat"],
                                     lng: @google_res[@res_num]["results"][ @place_num ]["geometry"]["location"]["lng"]
                          )

          if shop.save
            # @memo_exists.push("保存しました")
          else
            # @memo_exists.push("保存失敗")
          end
       end

        # Memoがデータベースに存在しなかったら作成、保存
        if !Memo.exists?(user_id: current_user.id, place_id: @google_res[@res_num]["results"][@place_num]["place_id"])
          memo = Memo.new(  user_id: current_user.id, 
                           place_id: @google_res[@res_num]["results"][ @place_num ]["place_id"],
                               memo: "",
                              count: 0,
                           favorite: 0
                          )
          if memo.save
          else
          end
        end
        @place_num += 1
        @total += 1
      end
      @res_num += 1
    end
    # 並べ替え
    @sorted_shops = sort_shops(@shops, post_sort, @total)
    render json: { "succes": true,
                     "data": {
                                 uid: current_user.id,
                               total: @total,
                                sort: post_sort,
                                shop: @sorted_shops.as_json
                              }
                  }

  end
end
