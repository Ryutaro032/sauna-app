class PostsController < ApplicationController
  before_action :authenticate_user!

  def new
    place_id = params[:place_id]
    @client = google_places_client
    place_details = @client.spot(place_id, language: 'ja')
    @post = Post.new(name: place_details.name)
  end

  def create
    @post = current_user.posts.new(review_params)
    @post.user_id = current_user.id
    @post.name = params[:post][:name]
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

  def google_places_client
    ::GooglePlaces::Client.new(ENV.fetch('GOOGLE_API_KEY'))
  end

  def review_params
    params.require(:post).permit(:title, :review, :name)
  end
end
