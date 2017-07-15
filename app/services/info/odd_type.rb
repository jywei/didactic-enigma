module Info
  class OddType
    class << self
      def data
        %w(
          0 1 3 4 2097153
          65536 65537 65539 65540 nil
          327680 327681 327683 327684 nil
          nil 131073 131075 131076 nil
          nil 393217 393219 393220 nil
          nil 196609 196611 196612 nil
          nil 458753 458755 458756 nil
        )
      end

      def full
        [
          {
            ot_fullname: 'points',
            ot_name:     'point',
            ot_name_ch:  '讓分',
            ot:          3,
            index:       0
          },
          {
            ot_fullname: 'totals',
            ot_name:     'ou',
            ot_name_ch:  '大小',
            ot:          4,
            index:       1
          },
          {
            ot_fullname: 'money line',
            ot_name:     'ml',
            ot_name_ch:  '獨贏',
            ot:          1,
            index:       2
          },
          {
            ot_fullname: 'three way',
            ot_name:     'three_way',
            ot_name_ch:  '三路',
            ot:          0,
            index:       2
          },
          {
            ot_name:     'one_win',
            ot_name_ch:  '一輸二贏',
            ot:          3,
            index:       3
          },
          {
            ot_fullname: 'odd/even',
            ot_name:     'odd_even',
            ot_name_ch:  '單雙',
            ot:          2_097_153,
            index:       4
          }
        ]
      end

      def basics
        full.reject { |n| n[:ot_name] == 'one_win' }
      end

      def ot_name_shorten_from(long_ot_name)
        if long_ot_name.include?('three way')
          'three_way'
        elsif long_ot_name.include?('money line')
          'ml'
        elsif %w(points spread).any? { |n| long_ot_name.include?(n) }
          'point'
        elsif long_ot_name.include?('totals')
          'ou'
        elsif long_ot_name.include?('odd/even')
          'odd_even'
        end
      end

      def ot
        to_hash :ot_name, :ot
      end

      def ch
        to_hash :ot_name, :ot_name_ch
      end

      def indexes
        to_hash :ot_name, :index
      end

      def types
        full.map { |n| n[:ot_name] }
      end

      def ot_types
        %w(full ht hf q1 q2 q3 q4)
      end

      def full?(ot)
        ot_in?(0..4, ot)
      end

      def ht?(ot)
        ot_in?(5..8, ot)
      end

      def hf?(ot)
        ot_in?(10..13, ot)
      end

      def q1?(ot)
        ot_in?(16..18, ot)
      end

      def q2?(ot)
        ot_in?(21..23, ot)
      end

      def q3?(ot)
        ot_in?(25..27, ot)
      end

      def q4?(ot)
        ot_in?(29..31, ot)
      end

      def ot_in?(range, ot)
        range.to_a.include? data.index(ot.to_s)
      end

      def compact
        data.select { |n| n != 'nil' }
      end

      def query_string
        compact.join(',')
      end

      def threeway?(ot)
        true if data_index(ot).zero?
      end

      def totals?(ot)
        true if data_index(ot) == 3
      end

      def points?(ot)
        true if data_index(ot) == 2
      end

      def moneyline?(ot)
        true if data_index(ot) == 1
      end

      def ot_to_odd_columns(ot)
        case data_index(ot)
        when 0
          [:o1, :o2, :o3]
        when 1
          [:o1, :o3, nil]
        when 2, 3
          [:o1, :o2, nil]
        end
      end

      def by_sport(name)
        if name == 'soccer' || name == 'test'
          ch.map { |k, v| { 'en' => k, 'ch' => v } unless k == 'ml' }.compact
        else
          ch.map { |k, v| { 'en' => k, 'ch' => v } unless k == 'three_way' }.compact
        end
      end

      private

      def data_index(ot)
        i = data.index(ot.to_s)
        return if i.nil?
        i % 5
      end

      def to_hash(column_1, column_2)
        full.each_with_object({}) do |type, result|
          result[type[column_1]] = type[column_2]
        end.with_indifferent_access
      end
    end
  end
end
