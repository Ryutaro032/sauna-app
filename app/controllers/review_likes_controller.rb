class ReviewLikesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_post

  protect_from_forgery :except => [:post,:destroy]

  def create
    @post.review_likes.create(user: current_user)
    @post.save
  end

  def destroy
    like = @post.review_likes.find_by(user: current_user)
    if like
      like.destroy
    end
  end


  private

  def find_post
    @post = Post.find(params[:post_id])
  end
end
