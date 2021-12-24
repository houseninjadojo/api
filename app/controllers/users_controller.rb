class UsersController < ApplicationController
  before_action :authenticate_request!, except: [:create]

  def create
    user = User.new(create_params)
  end

  private

  def create_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone_number, :gender)
  end
end
