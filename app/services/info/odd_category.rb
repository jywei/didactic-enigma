module Info
  class OddCategory
    class << self
      def data
        @data ||= {
          '1' => {
            name: 'all',
            ch:   '全部'
          },
          '2' => {
            name: 'full',
            ch: '全場'
          },
          '3' => {
            name: 'ht',
            ch: '上半場'
          },
          '4' => {
            name: 'hf',
            ch: '下半場'
          },
          '5' => {
            name: '',
            ch: '特別投注'
          },
          '6' => {
            name: '',
            ch: '波膽'
          },
          '7' => {
            name: '',
            ch: '入球數'
          },
          '8' => {
            name: '',
            ch: '半全場'
          },
          '9' => {
            name: '',
            ch: '過關'
          },
          '10' => {
            name: '',
            ch: '滾球'
          },
          '11' => {
            name: 'q1',
            ch: '第一節'
          },
          '12' => {
            name: 'q2',
            ch: '第二節'
          },
          '13' => {
            name: 'q3',
            ch: '第三節'
          },
          '14' => {
            name: 'q4',
            ch: '第四節'
          }
        }
      end

      # def array
      #   data.map { |k, v| { type: 'halves', id: k.to_i, name: v[:ch] } }
      # end

      def array(category = nil)
        if category.present?
          sport = category.sport
          data.map do |k, v|
            {
              type:        'halves',
              id:          k.to_i,
              name:        v[:ch],
              sport_id:    sport.leader_spid,
              sport_name:  sport.display_name || sport.name,
              league_id:   category.id,
              league_name: category.display_name || category.name
            }
          end
        else
            data.map { |k, v| { type: 'halves', id: k.to_i, name: v[:ch], sport_id: '未設定', sport_name: '未設定', league_id: '未設定', league_name: '未設定' } }
        end
      end

      def eql?(id, name)
        data[id.to_s][:name] == name
      end

      def to_ch(name)
        @en_to_ch ||= data.each_with_object({}) do |obj, result|
          result[obj[1][:name]] = obj[1][:ch]
        end
        @en_to_ch[name]
      end

      def to_en(name)
        @ch_to_en ||= data.each_with_object({}) do |obj, result|
          result[obj[1][:ch]] = obj[1][:name]
        end
        @ch_to_en[name]
      end

      def en_to_id(en)
        @en_to_id ||= data.reduce({}) {|result, category|
          result[category[1][:name]] = category[0]
          result
        }
        @en_to_id[en].to_i == 0 ? nil : @en_to_id[en].to_i
      end

      def allow_all?(id)
        id.to_s == '1'
      end
    end
  end
end
