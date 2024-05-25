class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update]

  def show
    if @user
      @favorites = @user.favorites.includes(:facility)
      @user_reviews = @user.posts
    elsif current_user
      @favorites = current_user.favorites.includes(:facility)
      @user_reviews = current_user.posts
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to user_path(current_user)
    else
      render 'edit'
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :my_rule, :icon_image)
  end
end
