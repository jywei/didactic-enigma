# 部位，哈哈
class Offer::Position < ApplicationRecord
  has_many :offers
  belongs_to :match

  def self.position_meter(args)
    distant_percentage = args[:thresholds].keys.each_with_object({}) do |team, result|
      distance = args[:current_positions][team] - args[:thresholds][team]
      modifier = args[:thresholds][team] < 0 ? 1 : -1
      result[team] = (distance.to_f / args[:thresholds][team].to_f rescue 0).round(3) * modifier
    end
    distant_percentage.map { |k, v| [k, ((v + 1) * 100).round(3)] }.to_h
  end

  def self.update_with(afu_offers)
    all.each do |position|
      offer = afu_offers[position.offer_name]
      unless offer
        raise("#{position.offer_name} not found in afu_match with match_id ##{position.match.id}")
      end
      position.update(
        h_position:  offer[:positions][:h],
        a_position:  offer[:positions][:a],
        d_position:  offer[:positions][:d] || nil,
        h_threshold: offer[:thresholds][:h],
        a_threshold: offer[:thresholds][:a],
        d_threshold: offer[:thresholds][:d] || nil,
        h_distance:  offer[:distances][:h],
        a_distance:  offer[:distances][:a],
        d_distance:  offer[:distances][:d] || nil
      )
    end
  end
end
