class MocksController < ApplicationController
  def index
    if @log = Log::Push.last
      time    = @log.created_at.in_time_zone("Asia/Taipei")
      @ts     = time.strftime("%Y-%m-%d %H:%M:%S")
      @result = @ts > Time.now - 2.minute ? "正常" : "可能異常"
    end

    begin
      @tx_worker_client = Odd::Query.new
      if @tx_log = @tx_worker_client.last_tx_log
        tx_time    = @tx_log["last_updated"] + 8.hours
        @tx_ts     = tx_time.strftime("%Y-%m-%d %H:%M:%S")
        @tx_result = @tx_ts > Time.now - 2.minute ? "正常" : "可能異常"
      end
      @tx_worker_client.close
    rescue => e
      e.message.include?("Unknown database") ? nil : raise(e)
    end
    @workers = queues.map do |q|
      {
        name: q,
        count: $worker.llen("worker/#{q}"),
        last_updated: ($worker.get("worker/#{q}/timestamp") || "尚未執行"),
        processing_time: ($worker.get("worker/#{q}/processing_time") || "尚未執行")
      }
    end
  end

  def delete_orders
    Order.delete_all
    Order::Item.delete_all
    redirect_to '/history'
  end

  def manager
    User.find_or_create_by(username: 'manager') do |u|
      # u.email = 'bbb@jjj.com'
      u.username = 'test@xxx.com'
      u.encrypted_password = '12345678'
    end
    set_var
    @modifiers = true
  end

  def player
    find_player
    set_var
    @modifiers = false
  end

  def results
    raise 'No afu match found in redis' unless $redis.afu_matches?
    User.find_or_create_by(username: 'result_manager') do |u|
      # u.email = 'aaa@bbb.com'
      u.username = 'test@xxx.com'
      u.encrypted_password = '12345678'
    end
    @manager = true
    category_ids = Category.where(name: ['MLB', 'NBA']).ids
    @result_matches = Match.includes(:hteam, :ateam, :category).where(category_id: category_ids).active.group(:leader_id)
  end

  def results_submit
    msg = ""
    if @resulting_matches = Match.where(leader_id: params[:leader_id])
      @resulting_matches.each { |match| match.close_with(params[:h_score], params[:a_score]) }
      msg = "success"
    else
      msg = "fail"
    end
    render json: { result: msg }
  end

  def parlays
    find_player
    set_parlay_var
    render "parlays"
  end

  def set_parlay_var
    raise 'No afu match found in redis' unless $redis.afu_matches?
    @matches = Match.authentic.active.sample(rand(2..5)).map do |match|
      m = $redis.afu_match!(match.id)
      m[:offer] = m[:parlay].map {|key, value|
        if value[:stat] == 'normal'
          value
        end
      }.compact.first
      m
    end
  end

  def set_var
    raise 'No afu match found in redis' unless $redis.afu_matches?
    @match = if params[:category_id]
               $redis.afu_match!(Category.find(params[:category_id]).matches.active.to_a.sample.key)
             elsif params[:match_key]
               $redis.afu_match!(params[:match_key].to_s)
             else
               $redis.random_afu_match
             end
    @offer = if params[:offer]
               @match[:play][params[:offer].to_sym]
             else
               @match[:play][:point]
             end
    @parlay = if params[:offer]
                @match[:parlay][params[:offer].to_sym]
              else
                @match[:parlay][:point]
              end
    list_cate = Match.where("matches.active = ?", true).group("matches.category_id").having("count(matches.id) > 10").pluck(:category_id)
    # list_cate = Match.where(active: true).group("category_id").size.select { |_k, v| v > 10 }.map { |x, _y| x }
    @list_sports = Category.where("id in (?)", list_cate).pluck(:spid, :id, :name)
                           .reduce({}) { |result, ele|
                             !result.has_key?(ele[0]) && result[ele[0]] = []
                             result[ele[0]].push( {id: ele[1], name: ele[2]} )
                             result
                           }

    #@sports = Sport.active.includes(categories: :matches).map do |sport|
    #  {
    #    name: sport.ch,
    #    categories: sport.categories.map {|category|
    #      {
    #        name: category.name,
    #        id: category.id
    #      } if category.matches.any?
    #    }.compact
    #  }
    #end
  end

  def cookies_reset
    cookies.to_h.keys.each {|key| cookies.delete(key.to_sym)}
    redirect_to "/"
  end

  def asians
    @asians = Offer::Asian.order("created_at desc").limit(100)
  end

  def recalculate_asians
    asians = Offer::Asian.order("created_at desc").limit(100)
    Offer::Asian.delete(asians.pluck(:id))
    Offer.where("id in (?)", asians).each(&:asia_offer)
    redirect_to "/asians"
  end

  def reasian
    asian = Offer::Asian.find(params[:id])
    asian.offer.asia_offer && asian.delete
    redirect_to "/asians"
  end

  def history
    @orders = Order.history
  end

  def delete_all
    queues.each do |q|
      $worker.del("worker/#{q}")
      $worker.del("worker/#{q}/timestamp")
      $worker.del("worker/#{q}/processing_time")
    end
    redirect_to "/"
  end

  def queues
    %w(push_log cache push_match push_variant_offer broadcast push_offer)
  end

  def broadcast
    set_var
  end

  def send_broadcast
    args = params.to_unsafe_h.except(:controller, :action, :channel, :channel_action, :"handicapped-head", :"handicapped-proportion", :"handicapped-modifier")
    handicapped_hash = {}
    args.each do |k, v|
      args[k] = args[k].to_f unless k.in? %w(_match_id _halves_match_id match_id last_updated offer handicapped-head handicapped-proportion handicapped-modifier)
      handicapped_hash[k.gsub("handicapped-", "")] = v if k.include?("handicapped")
    end
    args["handicapped"] = {
      head: params[:"handicapped-head"].to_i,
      proportion: params[:"handicapped-proportion"].to_i,
      modifier: params[:"handicapped-modifier"].to_i
    }
    args[:match_id] = args[:_halves_match_id]
    args[:last_updated] = args[:last_updated].to_i
    args[:action] = params[:channel_action]
    ActionCable.server.broadcast(params[:channel], args.to_h)
    render json: "ok"
  end

  protected

    def find_player
      User.find_or_create_by(username: 'player') do |u|
        # u.email = 'aaa@xxx.com'
        u.username = 'test@xxx.com'
        u.encrypted_password = '12345678'
      end
    end

end
