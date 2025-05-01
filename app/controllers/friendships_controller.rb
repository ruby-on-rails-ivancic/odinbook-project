class FriendshipsController < ApplicationController
  def create
    @friendship = current_user.sent_friendships.build(friendship_params)
    @user = User.find(friendship_params[:receiver_id])
    respond_to do |format|
      if @friendship.save
        format.turbo_stream
        format.html { redirect_to users_path, notice: "Friend request sent." }
      else
        format.turbo_stream
        format.html { redirect_to users_path, alert: "Unable to send friend request." }
      end
    end
  end

  def update
    @friendship = Friendship.find(params[:id])

    if @friendship.receiver == current_user
      @friendship.update(status: 1)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to users_path, notice: "Friend request accepted." }
      end
    else
      redirect_to users_path, alert: "You are not authorized to accept this request."
    end
  end

  def destroy
    @friendship = Friendship.find(params[:id])
    # @user = User.find(friendship_params[:receiver_id])
    @user = @friendship.requester == current_user ? @friendship.receiver : @friendship.requester

    if @friendship.requester == current_user || @friendship.receiver == current_user
      @friendship.destroy!
      respond_to do |format|
          format.turbo_stream
          format.html { redirect_to users_path, notice: "Friend request rescinded." }
      end
    else
      format.turbo_stream
      format.html { redirect_to users_path, alert: "Unable to rescind request." }
    end
  end

  private

  def friendship_params
    params.expect(friendship: [ :requester_id, :receiver_id, :status ])
  end
end
