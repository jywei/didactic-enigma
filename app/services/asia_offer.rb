require 'csv'

module AsiaOffer
  class << self
    attr_accessor :base_asia

    def convert_to_asia(offer, default_prob)
      @base_asia = build(offer)
      @base_asia.asia_offer.flat_head ? @base_asia.build_asia(default_prob) : nil
    end

    # for testing purpose
    def convert_to_asia_with_head(offer, default_prob, head)
      @base_asia = build(offer)
      @base_asia.set_flat_head(offer, offer.siblings.to_a, head)
      @base_asia.asia_offer.flat_head ? @base_asia.build_asia(default_prob) : nil
    end

    def build(offer)
      BaseAsia.new(offer)
    end

    def flat(offers)
      raise "Offer is empty" if offers.nil?
      while offer = offers.shift
        min ||= offer
        check_otname?(offer.name, :ou) && (min = ((offer.h_oppo - offer.a_oppo).abs > (min.h_oppo - min.a_oppo).abs) ? min : offer)
      end
      check_otname?(min.name, :ou) ? min : nil
    end

    def handicap_team(offer)
      case offer.name.to_sym
      when :ml
        offer.h_oppo > 0.5 ? :h : :a
      when :point
        offer.head < 0 ? :h : :a
      else
        :h
      end
    end

    def default_prob(redis, key, file)
      default = { baseball: { point: {}, ou: {} }, basketball: { point: 0.025, ou: 0.015 } }
      ot_type = nil
      CSV.foreach(file) do |line|
        line.size == 1 && ot_type = line[0].to_sym
        next if line.empty? || line.size == 1
        send "parse_csv_#{ot_type}".to_sym, default[:baseball][ot_type], line
      end
      return (redis.set(key, Marshal.dump(default)) && "Succeed set default prob")
    end

    def get_default_prob(redis, key)
      redis.get(key) ? Marshal.load(redis.get(key)) : nil
    end

    def get_percentage_of(offer)
      case offer.sport
      when :basketball
        { interval: 4, percentage: 25 }
      when :baseball
        check_otname?(offer.name, :point, :ml) ? { interval: 20, percentage: 5 } : { interval: 10, percentage: 10 }
      end
    end

    def check_otname?(origin_name, *ot_name)
      origin_name = origin_name.to_sym
      ot_name.size.eql?(1) ? origin_name.eql?(ot_name[0]) : ot_name.include?(origin_name)
    end

    def asianable?(offer)
      asian_ot?(offer.name) && asian_sport?(offer.category.sport.name)
    end

    def asian_ot?(name)
      check_otname?(name, :ml, :ou, :point)
    end

    def asian_sport?(name)
      name.in? %w(baseball basketball)
    end

    def find_sport(offer)
      offer.category.sport.name.to_sym
    end

    def find_a_score_prob(base, default_prob, main_head)
      offer = base.asia_offer
      begin
        value =
          case offer.sport
          when :baseball
            if check_otname?(offer.name, :ou)
              default_prob.dig(offer.sport, offer.name, offer.halves, main_head.abs.to_s)
            elsif check_otname?(offer.name, :ml, :point)
              default_prob.dig(offer.sport, :point, offer.handicap_team, main_head.abs.to_s, find_prob_range(base.get_main_prob), offer.flat_head.to_s)
            end
          when :basketball
            default_prob.dig(offer.sport, offer.name)
          end
          value ? value : 0.06
      rescue Exception
        return (base.is_half ? 0.03 : 0.06)
      end
    end

    private

    def parse_csv_point(point_datas, line)
      index, score_prob = 4, {}
      team = line[0].to_sym
      (6..11.5).step(0.5).each do |head|
        score_prob[head.to_s] = line[index].to_f
        index += 1
      end
      (point_datas[team] ||= {}) && (point_datas[team][line[1].to_f.to_s] ||= {})
      point_datas[team][line[1].to_f.to_s]["#{line[2]}-#{line[3]}"] = score_prob
      point_datas
    end

    def parse_csv_ou(ou_datas, line)
      halfs = line[0].to_sym
      ou_datas[halfs] ||= {}
      ou_datas[halfs][line[1].to_f.to_s] = line[2].to_f
      ou_datas
    end

    def find_prob_range(prob)
      odd_range = [ [1, 0.625], [0.624, 0.588], [0.587, 0.556], [0.555, 0.527], [0.526, 0.5], [0.499, 0.4] ].select { |range| (range[1]..range[0]).include? prob.to_f }

      raise("No range of odd") if odd_range.empty?
      (->(odd) { "#{odd[0]}-#{odd[1]}" }).call(odd_range[0])
    end

  end

  # Base asia object
  class BaseAsia
    BaseOffer = Struct.new(:id, :name, :sport, :head, :prob, :flat_head, :handicap_team,
                           :h_oppo, :a_oppo, :asia_head, :asia_prob, :standard_prob, :interval_prob, :halves)

    attr_accessor :asia_offer, :percentage_of_interval

    def initialize(offer)
      @asia_offer = BaseOffer.new(offer.id, offer.name.to_sym, nil, offer.head.to_f, 0, nil, nil,
                                  offer.h_oppo.round(4), offer.a_oppo.round(4), 0.0, 0, 0, 0.0, nil)
      set_handicap_team
      set_flat_head(offer, offer.siblings.to_a)
      set_sport(offer)
      set_halves(offer)
      set_interval(@asia_offer)
    end

    def build_asia(default_prob)
      change_head(default_prob)
      set_asia_value(calculate)
      export_data
    end

    def set_halves(offer)
      asia_offer.halves = offer.halves.to_sym
    end

    def set_asia_value(result)
      asia_offer.prob = result
      asia_offer.asia_head, asia_offer.asia_prob =
      if is_half
        (result >= 0 ? [(asia_offer.head - 0.5), (result - 100)] : [(asia_offer.head + 0.5), (100 + result)])
      else
        [asia_offer.head, result]
      end

      asia_offer.standard_prob = standard_rounding
    end

    def set_interval(offer)
      @percentage_of_interval = AsiaOffer.get_percentage_of(offer)
    end

    def set_flat_head(offer, offers, head = nil)
      if head
        asia_offer.flat_head = head.to_f
      elsif AsiaOffer.check_otname?(offer.name, :ou)
        asia_offer.flat_head = offer.head.to_f
      elsif flat_offer = AsiaOffer.flat(offers)
        asia_offer.flat_head = flat_offer.head.to_f
      end
    end

    def set_sport(offer)
      asia_offer.sport = AsiaOffer.find_sport(offer)
    end

    def set_handicap_team
      asia_offer.handicap_team = AsiaOffer.handicap_team(asia_offer)
    end

    def set_main_prob(value)
      asia_offer.send("#{asia_offer.handicap_team}_oppo=", value)
    end

    def set_main_head(value)
      asia_offer.head = value.abs
    end

    def get_main_prob
      asia_offer.send("#{asia_offer.handicap_team}_oppo")
    end

    def is_half
      asia_offer.head % 1 != 0
    end

    private

    def change_head(default_prob)
      main_prob = get_main_prob
      main_head = asia_offer.head
      while (0.5 - main_prob).abs > (values = AsiaOffer.find_a_score_prob(self, default_prob, main_head))
        if (main_prob - 0.5) > 0
          main_prob -= values
          AsiaOffer.check_otname?(asia_offer.name, :ou) ? main_head += 0.5 : main_head -= 0.5
        else
          main_prob += values
          AsiaOffer.check_otname?(asia_offer.name, :ou) ? main_head -= 0.5 : main_head += 0.5
        end

        set_main_prob(main_prob)
      end

      set_main_head(main_head)
      asia_offer.asia_head = main_head.abs
      asia_offer.interval_prob = values
    end

    def calculate
      (( 0.5 - get_main_prob ) / ( asia_offer.interval_prob / percentage_of_interval[:interval] ) * percentage_of_interval[:percentage]).to_f
    end

    def standard_rounding
      (asia_offer.asia_prob / percentage_of_interval[:percentage]).round * percentage_of_interval[:percentage]
    end

    def get_sign_value(prob = nil)
      prob ||= asia_offer.asia_prob
      prob >= 0 ? "+#{prob.to_i.abs}" : "-#{prob.to_i.abs}"
    end

    def export_data
      { base: asia_offer, asia: asia_format }
    end

    def asia_format
      {
        origin_format: "#{asia_offer.head}#{get_sign_value(asia_offer.prob)}",
        asia_format: {
          origin: "#{asia_offer.asia_head}#{get_sign_value}",
          standard: "#{asia_offer.asia_head.to_i}#{get_sign_value(asia_offer.standard_prob)}"
        }
      }
    end
  end
end
