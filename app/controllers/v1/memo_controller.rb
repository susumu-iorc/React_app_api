class V1::MemoController < ApplicationController  
  before_action :authenticate_v1_user!

  def get # memo 取得
    # postが送られてきているかどうか
    if request.body.read.blank?
      render json: { "success": false, "message": "データが正常にpostされませんでした"}
      return
    end

    # postの内容解析
    post_body = JSON.parse(request.body.read)

    # 指定されたメモが存在するかどうか
    if !Memo.exists?(place_id: post_body["place-id"], user_id: current_user.id)
      render json: { "succes": false, "data": { "uid": current_user.id, "place-id": post_body["place-id"]}}
      return
    end

    # メモ情報の取得
    @shop = Shop.find_by( place_id: post_body["place-id"])
    @memo = Memo.find_by( place_id: post_body["place-id"], user_id: current_user.id)

    render json: { "success": true,
                      "data": {
                                         "uid": current_user.id,
                                    "place-id": post_body["place-id"],
                                   "shop-name": @shop["shop_name"],
                                "shop-address": @shop["shop_address"],
                                    "shop-lat": @shop["lat"],
                                    "shop-lng": @shop["lng"],
                                        "memo": @memo["memo"],
                                       "count": @memo["count"],
                                    "favorite": @memo["favorite"]
                               }
                  }
  end

  def update # memo の更新
    # postが送られてきているかどうか
    if request.body.read.blank?
      render json: { "success": false, "message": "データが正常にpostされませんでした"}
      return
    end

    # postの内容解析
    post_body = JSON.parse(request.body.read)

    # 指定されたメモが存在するかどうか
    if !Memo.exists?(place_id: post_body["place-id"], user_id: current_user.id)
      render json: { "success": false, "data": { "uid": current_user.id, "place-id": post_body["place-id"]}}
      return
    end

    # メモ情報の取得
    @memo = Memo.find_by( place_id: post_body["place-id"], user_id: current_user.id)

    # メモ更新の際のレスポンス

    @memo_updt     = false
    @memo_sucs     = false
    @count_updt    = false
    @count_sucs    = false
    @favorite_updt = false
    @favorite_sucs = false

    # memo の更新
    if !post_body["memo"].blank?
      @memo_upd  = true
      @memo.memo = post_body["memo"]
      @memo_sucs = @memo.save
    end
    
    # count の更新
    if !post_body["count"].blank?
      @count_updt = true
      if post_body["count"] == @memo.count + 1 || post_body["count"] == @memo.count - 1
        @memo.count = post_body["count"]
        @count_sucs = @memo.save
      end
    end

    # favorite の更新
    if !post_body["favorite"].blank?
      @favorite_updt = true
      if post_body["favorite"] >= 0 && post_body["favorite"] <= 3
        @memo.favorite = post_body["favorite"]
        @favorite_sucs = @memo.save
      end
    end

    render json: { "success": true, 
                     "data": { 
                                            "uid": current_user.id,
                                       "place-id": post_body["place-id"],
                                    "memo-update": @memo_updt,
                                   "memo-success": @memo_sucs,
                                   "count-update": @count_updt,
                                  "count-success": @count_sucs,
                                "favorite-update": @favorite_updt,
                               "favorite-success": @favorite_sucs,
                                       "contents": {
                                                         "memo": @memo["memo"],
                                                        "count": @memo["count"],
                                                     "favorite": @memo["favorite"]
                                                    }
                              }
                  }
  end
end

