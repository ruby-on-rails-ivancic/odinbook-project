class LikesController < ApplicationController
  before_action :set_post
  def create
    @like = @post.likes.find_or_create_by(user: current_user)

    # redirect_to @post, notice: "You liked this post."
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to posts_path }
    end
  end

  def destroy
    @like = current_user.likes.find_by(post: @post)

    if @like
      @like.destroy
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to posts_path }
      end
      # redirect_to @post, notice: "You unliked this post."
    else
      redirect_to @post, alert: "Like"
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end
end
