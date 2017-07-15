class Api::V1::Player::BalancesController < Api::V1::ApplicationController
  api :GET, '/player/balances/weekly', "顯示使用者近三週下注數據"
  param :sport_id, String, "運動種類ID"
  param :type_id, String, "下注遊戲種類"
  formats ['json']
  example '"/api/v1/player/balances/weekly?sport_id=75,77,78&type_id=1"'
  example '
  [
    [
      {
      "name": "01/19 星期四",
      "amount": 0,
        "effective_amount": 0,
        "result": 0
      },
      {
        "name": "01/18 星期三",
        "amount": 0,
        "effective_amount": 0,
        "result": 0
      },
      {
        "name": "01/17 星期二",
        "amount": 1000,
        "effective_amount": 1000,
        "result": 0
      },
      {
        "name": "01/16 星期一",
        "amount": 0,
        "effective_amount": 0,
        "result": 0
      },
      {
        "name": "本週",
        "amount": 1000,
        "effective_amount": 1000,
        "result": 0
      }
    ],
    [
      {
        "name": "01/15 星期日",
        "amount": 0,
        "effective_amount": 0,
        "result": 0
      },
      {
        "name": "01/14 星期六",
        "amount": 0,
        "effective_amount": 0,
        "result": 0
      },
      {
        "name": "01/13 星期五",
        "amount": 0,
        "effective_amount": 0,
        "result": 0
      },
      {
        "name": "01/12 星期四",
        "amount": 0,
        "effective_amount": 0,
        "result": 0
      },
      {
        "name": "01/11 星期三",
        "amount": 0,
        "effective_amount": 0,
        "result": 0
      },
      {
        "name": "01/10 星期二",
        "amount": 0,
        "effective_amount": 0,
        "result": 0
      },
      {
        "name": "01/09 星期一",
        "amount": 0,
        "effective_amount": 0,
        "result": 0
      },
      {
        "name": "上週",
        "amount": 0,
        "effective_amount": 0,
        "result": 0
      }
    ],
    [
      {
        "name": "01/08 星期日",
        "amount": 0,
        "effective_amount": 0,
        "result": 0
      },
      {
        "name": "01/07 星期六",
        "amount": 0,
        "effective_amount": 0,
        "result": 0
      },
      {
        "name": "01/06 星期五",
        "amount": 0,
        "effective_amount": 0,
        "result": 0
      },
      {
        "name": "01/05 星期四",
        "amount": 0,
        "effective_amount": 0,
        "result": 0
      },
      {
        "name": "01/04 星期三",
        "amount": 0,
        "effective_amount": 0,
        "result": 0
      },
      {
        "name": "01/03 星期二",
        "amount": 0,
        "effective_amount": 0,
        "result": 0
      },
      {
        "name": "01/02 星期一",
        "amount": 0,
        "effective_amount": 0,
        "result": 0
      },
      {
        "name": "上上週",
        "amount": 0,
        "effective_amount": 0,
        "result": 0
      }
    ]
  ]
  '
  param_group :user_authentication, ::Api::V1::ApplicationController
  def weekly
    render json: current_user.weekly_balances(params)
  end
end
