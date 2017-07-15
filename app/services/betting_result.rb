class BettingResult
  class << self
    def calculate(order_or_item)
      raise "ActiveRecord Match is not exist!" unless check_match_exist
      if order_or_item.is_a? Order::Item::ActiveRecord_Relation
        order_or_item.map { |item| create(item).runner }
      else
        order_or_item.items.map { |item| create(item).runner }
      end
    end

    def check_match_exist
      Module.const_defined?(:Match) ? true : (::Match)
    end

    private

      def create(item)
        TmpItem.new(item.id, item.offer_name, item.match.h_score, item.match.a_score, item.type_flag.to_sym, item.target.to_sym, item.odd,
                    item.head, item.proportion, item.offer.handicapped_team, nil, nil)
      end

      TmpItem = Struct.new(:origin_id, :offer_name, :h_score, :a_score, :type, :target, :odd,
                           :head, :proportion, :handicap, :result_code, :result_target) do

        def runner
          send(:"cal_#{offer_name}")
          convert_format
        end

        def convert_format
          {
            id: origin_id,
            result_target: result_target,
            result_code: result_code
          }
        end

        def cal_ou
          save_code( (h_score + a_score) <=> head )
        end

        def cal_point
          save_code( (handicap == "h" ? h_score <=> (a_score + head) : (h_score + head) <=> a_score) )
        end

        def cal_ml
          save_code( h_score <=> a_score )
        end

        def cal_three_way
          cal_ml
        end

        def cal_one_win
          save_code( (handicap == "h" ? h_score <=> (a_score + 1.5) : (h_score + 1.5) <=> a_score) )
        end

        def cal_odd_even
          save_code( (h_score + a_score) % 2 != 0 ? -1 : 1 )
        end

        def save_code(code)
          self.result_target =
            case code
            when 0
              :d
            when 1
              :h
            when -1
              :a
            end
          check_pass
        end

        def check_pass
          self.result_code =
          if result_target != :d
            target == result_target ? :pass : :fail
          elsif result_target == :d
            target == :d ? :pass : offer_name == "three_way" ? :fail : :draw
          end
        end

    end # --end TmpItem method

  end
end
