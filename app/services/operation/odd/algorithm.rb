module Operation
  class Odd
    # 包含整個app都有共用的演算法
    module Algorithm
      # 把機率加上水錢，轉為賠率
      def oppo_to_odd(oppo, water = 0.015)
        return 0.0 if oppo.to_f == 0.0
        (1 / (oppo * (1 + water)) - 1).round(3)
      end
    end
  end
end
