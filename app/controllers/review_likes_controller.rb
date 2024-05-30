class ReviewLikesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_post

  protect_from_forgery except: %i[post destroy]

  def create
    return unless user_signed_in?

    @post.review_likes.create(user: current_user)
    respond_to do |format|
      format.js
    end
  end

  def destroy
    like = @post.review_likes.find_by(user: current_user)
    like&.destroy

    respond_to do |format|
      format.js
    end
  end

  private

  def find_post
    @post = Post.find(params[:post_id])
  end
end
