class V1::General::IsLoginController < ApplicationController
  before_action :authenticate_v1_user!

  def index
    render json: { message: 'hello' }
  end
end
