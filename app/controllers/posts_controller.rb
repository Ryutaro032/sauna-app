class PostsController < ApplicationController
  before_action :authenticate_user!

  def new
    place_id = params[:place_id]
    @client = ::GooglePlaces::Client.new(ENV.fetch('GOOGLE_API_KEY'))
    place_details = @client.spot(place_id, language: 'ja')
    @post = Post.new(
      name: place_details.name,
      )
  end

  def create
    @post = current_user.posts.new(review_params)
    @post.user_id = current_user.id
    @post.name = params[:post][:name] 
    if @post.save
      flash[:success] = I18n.t('flash.review.success')
      redirect_to root_path
    else
      flash[:error] = I18n.t('flash.review.error')
      render :new
    end
  end

  private

  def review_params
    params.require(:post).permit(:title, :review, :name)
  end
end
