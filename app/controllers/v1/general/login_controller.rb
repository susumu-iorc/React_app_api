class V1::General::LoginController < ApplicationController
    before_action :authenticate_v1_user!

    def index
      render json: { message: 'hello' }
    end
  end
  