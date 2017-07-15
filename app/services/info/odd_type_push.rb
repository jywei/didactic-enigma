module Info
  class OddTypePush
    class << self
      def basics
        [
          {
            ot_fullname: 'points',
            ot_name:     'point',
            ot_name_ch:  '讓分',
            index:       0
          },
          {
            ot_fullname: 'totals',
            ot_name:     'ou',
            ot_name_ch:  '大小',
            index:       1
          },
          {
            ot_fullname: 'money line',
            ot_name:     'ml',
            ot_name_ch:  '獨贏',
            index:       2
          },
          {
            ot_fullname: 'three way',
            ot_name:     'three_way',
            ot_name_ch:  '三路',
            index:       2
          },
          {
            ot_name:     'one_win',
            ot_name_ch:  '一輸二贏',
            index:       3
          },
          {
            ot_fullname: 'odd/even',
            ot_name:     'odd_even',
            ot_name_ch:  '單雙',
            index:       4
          }
        ]
      end

      def data
        @data ||= full + ht + hf
      end

      def name(ot_id, head, tx_spid = nil)
        data.each do |offer|
          next unless offer[:ot].to_i == ot_id
          if basketball_three_way?(ot_id, tx_spid)
            return 'ml'
          elsif point?(ot_id) && [1.5, -1.5].include?(head.to_f.round(2))
            return 'one_win'
          else
            return offer[:ot_name]
          end
        end
        nil
      end

      def ot_id_to_index(ot_id)
        type_to_i(type(ot_id))
      end

      def basketball_three_way?(ot_id, tx_spid = nil)
        return false if tx_spid.nil?
        tx_spid.to_i == 3 && %w(2 21 237).include?(ot_id.to_s)
      end

      def multi_heads?(ot_name)
        ot_name.in? %w(ou point)
      end

      def match_ot_name(ot_name, ot_id)
        data.map { |o| o[:ot] if o[:ot_name] == ot_name }.compact.include?(ot_id)
      end

      def full
        assign_ot_and_type(%w(59 61 63 245 59 6), 'full') << {
          ot_fullname: 'totals',
          ot_name:     'ou',
          ot_name_ch:  '大小',
          ot:          246,
          index:       1
        }
      end

      def ht
        assign_ot_and_type(%w(60 62 64 237 60 31), 'ht')
      end

      def hf
        assign_ot_and_type(%w(17 20 648 21 17 15), 'hf')
      end

      # ot_id order: point ou ml three_way one_win odd/even
      def assign_ot_and_type(ot_ids, type)
        types = basics.dup
        ot_ids.each_with_index do |ot, i|
          types[i][:ot]      = ot.to_i
          types[i][:ot_type] = type
        end
        types
      end

      %w(full ht hf).each do |ot_type|
        define_method "#{ot_type}?".to_sym do |ot_id|
          send(ot_type.to_sym).map { |n| n[:ot] }.include?(ot_id.to_i)
        end
      end

      %w(point ou ml).each do |ot_name|
        define_method "#{ot_name}?".to_sym do |ot_id|
          match_ot_name(ot_name, ot_id)
        end
      end

      def type(ot_id)
        if full?(ot_id)
          'full'
        elsif ht?(ot_id)
          'ht'
        elsif hf?(ot_id)
          'hf'
        end
      end

      def type_to_ch(name)
        case name
        when 'full'
          '全場'
        when 'ht'
          '上半場'
        when 'hf'
          '下半場'
        else
          name
        end
      end

      def available_ot_desc
        data.inject('') { |result, ot| result << "#{ot[:ot_name]}: #{ot[:ot]}, " }
      end

      def type_to_i(type)
        case type
        when 'full' then 0
        when 'ht'   then 1
        when 'hf'   then 2
        when 'q1'   then 3
        when 'q2'   then 4
        when 'q3'   then 5
        when 'q4'   then 6
        end
      end

      def name_to_ch(name)
        basics.each do |type|
          return type[:ot_name_ch] if name == type[:ot_name]
        end
        nil
      end
    end
  end
end
