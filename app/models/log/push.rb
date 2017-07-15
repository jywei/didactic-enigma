# tx push feed log
class Log::Push < ApplicationRecord
  belongs_to :match, foreign_key: :tx_match_id, primary_key: :leader_id, optional: true
  belongs_to :offer, foreign_key: :tx_offer_id, primary_key: :leader_id, optional: true
  belongs_to :book_maker, optional: true

  scope :by_match, ->(id) { where(tx_match_id: id).includes(:book_maker).order('id DESC') }
  
  def push(message)
    puts message
    self.log = "#{log}- #{message}\n"
    self
  end

  def self.search(params)
    logs = all
    logs = logs.where(event:  params[:event])      if params[:event].present?
    logs = logs.where(action: params[:actions])    if params[:actions].present?
    logs = logs.where(book_maker_id: params[:book_maker_id]) if params[:book_maker_id].present?
    logs = logs.where(ot:     params[:ot])         if params[:ot].present?
    logs = logs.where(head:   params[:head])       if params[:head].present?
    if params[:date_start].present? && params[:date_end].present?
      check_time = (params[:date_start].to_time)..(params[:date_end].to_time.end_of_day)
      logs = logs.where(created_at: check_time)
    end
    logs
  end
end
