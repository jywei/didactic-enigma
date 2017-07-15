module SweepStake

  class << self
    def settled(orders)
      (orders.map { |order| runner(order) }).compact
    end

    def runner(order)
      response = {
         id: order.id,
         settle: true
      }
      response[:stake] =
        case order.type_flag.to_sym
        when :normal
          send(:"#{order.items.first.result_code}", order.amount, order.items.first)
        when :parlay
          parlay(order.amount, order.items)
        end

      response
    end

    def draw(amount, *items)
      amount * 0
    end

    def fail(amount, *items)
      amount * -1
    end

    def pass(amount, *items)
      ( amount * (main_odd(items[0]) - 1) ).round
    end

    def parlay(amount, items)
      if check_pass(items)
        odd = items.reduce(1) do |result, item|
          result *= main_odd(item)
          result
        end
        (amount * (odd - 1).round(3)).round
      else
        fail(amount)
      end
    end

    def check_pass(items)
      !items.any? { |item| item.result_code.to_sym == :fail }
    end

    def main_odd(item)
      odd = item.odd.to_f
      return (1 + odd) if item.result_code.to_sym == :pass
      case item.type_flag.to_sym
      when :normal
        1
      when :asian
        if item.proportion > 0
          1 + (odd * (item.proportion / 100.0).round(3))
        else
          ( 1 + (item.proportion / 100.0) ).round(3)
        end
      end
    end

  end
end
