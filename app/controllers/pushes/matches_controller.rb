class Pushes::MatchesController < ApplicationController
  def index
    ids = Log::Push.order('id DESC').limit(200).pluck(:tx_match_id).uniq
    @matches = Match.includes(category: :sport).where(leader_id: ids).order('id DESC').limit(200)

    @error_logs = Log::Push.where('has_error = ? OR action = ?', true, 'no_action').order('id DESC').limit(200)
    @logs = Log::Push.all.order('id DESC').limit(5)
  end

  def show
    if Match.find_by(id: params[:id]).nil?
      render json: "找不到場次"
      return
    end
    @match     = Match.includes(:offers).find(params[:id])
    @matches   = Match.includes(:offers).where(leader_id: @match.leader_id)
    @search_id = @match.id

    @logs      = Log::Push.by_match(@match.leader_id).search(params).order("created_at DESC")
    @search_params = params
    if params[:offer]
      @logs = @logs.where(ot_name: params[:offer])
      @offers = @match.offers.where(name: params[:offer])
      @flat = @offers.flat(params[:offer])
    end
  end
  
  def tx
    @search_id = params[:id]
    @logs      = Log::Push.by_match(@search_id).search(params)
    @search_params = params
  end

  def offers
    @match = Match.includes(:offers).find(params[:id])
    @offers = @match.offers.name_and_flat
    @afu_match = $redis.afu_match(@match.key)
    if @afu_match
      @current_offer_ids = @afu_match[:play].map {|k,v| v[:offer_id].to_i }
    end
  end

  def filter
    # params[:league] = "716" if params[:league].blank?
    # params[:league_id] = Category.find_by(name: params[:league]).id
    hash = Match::Open.query_by(params)
    @offers = hash[:offers]
    @matches = hash[:matches]
  end
end
