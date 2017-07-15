class User::Allotter < ApplicationRecord
  belongs_to :user

  class << self
    def oppos
      order(user_id: :desc).pluck(:oppo).map(&:to_f)
    end

    def create_default(user_id)
      Info::AllotterCategory.default_allotter(user_id) # .each { |allotter| create(allotter) }
    end

    def update_allotters(params)
      target_id     = params[:target_id]
      name          = params[:sport_name]
      adj_amount    = params[:adj_amount].to_f
      target_column = params[:target_column].to_sym
      user_id       = params[:user_id].to_i
      if find_by(user_id: user_id, name: name)[target_column].to_f < adj_amount
        false
      else
        transaction do
          find_by(user_id: target_id, name: name).update_attributes(target_column => adj_amount)
          AutoAdjust.new(params).adjust
        end
        true
      end
    rescue
      false
    end

  end # class self
end
