require "digest/md5"

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # Setup accessible (or protected) attributes for your model
  # attr_accessible :email, :password, :password_confirmation
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy

  # Outgoing friend requests
  # has_many :sent_friendships, class_name: "Friendship", foreign_key: "user_id", dependent: :destroy
  # Users that this user has requested to be friends with
  # has_many :sent_friends, through: :sent_friendships, source: :friend

  # Incoming friend requests
  # has_many :received_friendships, class_name: "Friendship", foreign_key: "friend_id", dependent: :destroy
  # Users that have requested to be friends with this User
  # has_many :received_friends, through: :received_friendships, source: :user
  has_many :sent_friendships, class_name: "Friendship", foreign_key: :requester_id, dependent: :destroy
  has_many :received_friendships, class_name: "Friendship", foreign_key: :receiver_id, dependent: :destroy

  # Helpers
  def friends
    sent = Friendship.where(requester_id: id, status: :accepted).pluck(:receiver_id)
    received = Friendship.where(receiver_id: id, status: :accepted).pluck(:requester_id)
    User.where(id: sent + received)
  end

  def friendship_with(other_user)
    Friendship.find_by(
      "(requester_id = :self_id AND receiver_id = :other_id) OR (requester_id = :other_id AND receiver_id = :self_id)",
      self_id: id, other_id: other_user.id
    )
  end


  has_many :received_requests, -> { where(friendships: { status: 0 }) }, through: :received_friendships, source: :requester
  has_many :sent_requests, -> { where(friendships: { status: 0 }) }, through: :sent_friendships, source: :receiver

  def all_pending_requests
    sent = Friendship.where(requester_id: id, status: :pending).pluck(:receiver_id)
    received = Friendship.where(receiver_id: id, status: :pending).pluck(:requester_id)
    User.where(id: sent + received)
  end


  has_many :likes, dependent: :destroy

  validates :username, presence: true, uniqueness: true

  def gravatar_url(size: 80)
    email_address = email.downcase.strip
    hash = Digest::MD5.hexdigest(email_address)
    "https://www.gravatar.com/avatar/#{hash}?s=#{size}&d=identicon"
  end
end
