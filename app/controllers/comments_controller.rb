class CommentsController < ApplicationController
  before_action :set_post
  before_action :set_comment, only: %i[ destroy ]

  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @post }
      end
    else
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace("new_comment", partial: "comments/form", locals: { post: @post, comment: @comment })
        }
        format.html { redirect_to @post, alert: "Comment can't be blank" }
      end
    end
  end

  def destroy
    if authorise_owner!(@comment)
      @comment.destroy
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @comment.post, notice: "Comment deleted." }
      end
    else
      flash[:alert] = "You cannot delete other users' comments."
      render @post, status: :unprocessable_entity
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def comment_params
    params.expect(comment: [ :content ])
  end
end
