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
      @Base = Base.find_by(user_id:current_user.id)
      render json: { succes: true , data:{uid:            current_user.id,
                                          user_post_code: @Base.user_post_code,
                                          user_pref:      @Base.user_pref,
                                          user_city:      @Base.user_city,
                                          user_area:      @Base.user_area,
                                          user_lat:       @Base.lat,
                                          user_lng:       @Base.lng} }
    else
      render json: { succes: false, data:{uid:current_user.id} }
    end
  end
end
