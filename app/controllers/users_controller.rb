class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[show edit update]
  before_action :set_user, only: %i[show edit update]

  def show; end

  def edit
    return if @user == current_user

    redirect_to user_path(@user)
  end

  def update
    if @user.update(user_params)
      redirect_to user_path(current_user)
    else
      logger.error @user.errors.full_messages
      render 'edit'
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:name, :my_rule, :icon_image)
  end
end
