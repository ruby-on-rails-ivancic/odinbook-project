class Friendship < ApplicationRecord
  belongs_to :requester, class_name: "User"
  belongs_to :receiver, class_name: "User"
  after_initialize :set_default_status, if: :new_record?

  enum :status, { pending: 0, accepted: 1, declined: 2 }
  validates :requester_id, uniqueness: { scope: :receiver_id } # no duplicates

  def set_default_status
    self.status ||= :pending
  end
end
