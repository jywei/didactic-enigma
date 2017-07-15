class User::Ancestor < ApplicationRecord
  belongs_to :user

  scope :upperlines, ->(id) { select(:id, :admin, :moderator, :supervisor, :director, :major_shareholder, :shareholder, :general_agent, :agent).where(user_id: id).first }
  scope :member,     -> { where.not(member: nil) }

  def player?
    member != nil
  end

  def self.downlines_count(ancestors, user)
    user_ancestors = ancestors.select{ |ancestor| ancestor[user.title] == user.id }
    user_ancestors.pluck(*user.downline_names_below).flatten.compact.uniq
  end

end
