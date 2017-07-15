class PushMatchJob < ApplicationJob
  queue_as :push_match

  def perform(offer_id, push_args)
    log = Log::Push.new
    offer = Offer.find(offer_id)
    match = Match.find_by(
      leader_id:     offer.match_leader_id, 
      book_maker_id: offer.book_maker_id,
      halves:        offer.halves
    )
    if match
      offer.update_column(:match_id, match.id)
      job = CacheSetterJob.perform_by_env('assign_offer', offer_id: offer.id, match_id: match.id)
      log.job(job.job_id)
    else
      match = Operation::Odd::Match.new(push_args, 'tx', log).create
      job = CacheSetterJob.perform_by_env('open_match', match_id: match.id)
      log.job(job.job_id)
    end
  rescue => e
    log.error!
    log.push("#{exception.class} #{exception.message}")
    e.backtrace.each {|b| log.push("Backtrace: #{b}") }
    raise e if Rails.env.test?
  ensure
    log[:log_duration] = DateTime.now.to_f - log[:log_start] 
    PushLogJob.perform_by_env(log)
  end
end
