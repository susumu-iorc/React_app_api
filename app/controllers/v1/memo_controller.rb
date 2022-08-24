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
      render json: { "succes": false, "data": { "uid": current_user.id, "place-id": post_body["place-id"]}}
      return
    end

    # メモ情報の取得
    @memo = Memo.find_by( place_id: post_body["place-id"], user_id: current_user.id)

    # memo の更新
    if !post_body["memo"].blank?
      @memo.update(memo: post_body["memo"])
    end
    
    # count の更新
    # favorite の更新
  end
end

