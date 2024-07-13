class PostsController < ApplicationController
  before_action :authenticate_user!

  def new
    @facility = Facility.find(params[:facility_id])
    @post = Post.new(facility_id: @facility.id)
  end

  def create
    @facility = Facility.find(params[:post][:facility_id])
    @post = current_user.posts.new(review_params)
    @post.user_id = current_user.id
    @post.name = @facility.name
    if @post.save
      flash[:success] = I18n.t('flash.post.review.success')
      redirect_to root_path
    else
      render :new
    end
  end

  def destroy
    @post = current_user.posts.find(params[:id])
    @post.destroy
    flash[:success] = I18n.t('flash.post.destroy.success')
    redirect_to user_path(current_user)
  end

  private

  def review_params
    params.require(:post).permit(:title, :review, :name, :facility_id)
  end
end
