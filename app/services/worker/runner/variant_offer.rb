class Worker::Runner::VariantOffer < Worker::Runner::Base
  queue_as :push_variant_offer

  def self.run(data)
    delete_duplicate(data[:offer_id])
    offer  = ::Offer.find(data[:offer_id])
    offers = ::Offer.where(
      name:            offer.name,
      halves:          offer.halves,
      book_maker_id:   offer.book_maker_id,
      match_leader_id: offer.match_leader_id
    )
    flat_offers = offers.to_a.select {|o| o.flat == true }
    current_flat_offer = flat_offers.first
    finder = ::Offer::Open::FlatFinder.new(offers)
    flat   = finder.find_one
    # first comparison || replace with a better head
    if flat_offers.size > 1 || flat.id != current_flat_offer.try(:id)
      finder.update_all
      Worker::Runner::Cache.run_by_env(action: 'replace_offer', match_id: flat.match_id, offer_id: flat.id) if flat.match_id
      # @push_log.push("Match ##{db_match.id} offer #{offer_ot_name} ##{current_flat_offer.try(:id)}(head: #{current_flat_offer.try(:head).try(:to_f)}) is replaced with ##{flat.id}(head: #{flat.head.to_f})")
      # job = CacheSetterJob.perform_by_env('replace_offer',
      #                               match_key: flat.match.key,
      #                               offer_id: flat.id
      #                              )
      # @push_log.job(job.job_id)
      # @replaced = true
    elsif flat.id == current_flat_offer.try(:id)
      # 多球頭的情況下若沒有取代，就把數值更新到原本的賠率上
      Worker::Runner::Cache.run_by_env(
        action: 'update_offer',
        offer_id: flat.id,
        match_id: flat.match_id,
        is_running:   data[:is_running],
        last_updated: data[:last_updated],
        stat_changed: data[:stat_changed]
      )
    else
      # @push_log.push("#{offer_ot_name} offer ##{flat.id}, head #{flat.head.to_f} is not replaced.")
    end
  end

  def self.delete_duplicate(offer_id)
    next_data = offer_id.to_s
    while next_data.include?(offer_id.to_s)
      next_data = $worker.db.lpop("worker/push_variant_offer").to_s
    end
    $worker.db.lpush("worker/push_variant_offer", next_data) unless next_data.blank?
  end
end
