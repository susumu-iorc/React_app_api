class V1::UserbaseController < ApplicationController
  before_action :authenticate_v1_user!

  def index
    if !Base.exists?(user_id: current_user.id)
      render json: { succes: 'false', data:{uid:current_user.id} }
    else
      render json: { succes: 'true', data:{uid:current_user.id} }
    end
  end
end
