class V1::MemoController < ApplicationController  
  before_action :authenticate_v1_user!
  def get
    post_body = JSON.parse(request.body.read)
    if !Memo.exists?(user_id: current_user.id, place_id: post_body["place-id"])
      render json: { succes: false, data:{uid:current_user.id, "place-id": post_body["place-id"]} }
    else
      @shop = Shop.find_by( place_id: post_body["place-id"])
      @memo = Memo.find_by( user_id:current_user.id, place_id: post_body["place-id"])
      result_data =  {
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
      render json: result_data
    end
  end
end
