class V1::General::LoginController < ApplicationController
    before_action :authenticate_v1_user!

    def index
      if !Base.exists?(user_id: current_user.id)
        render json: { message: current_user.id }
      else
        render json: { message: 'yep'}
      end
    end
  end
  