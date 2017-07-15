class Api::V1::CategoriesController < Api::V1::ApplicationController
  before_action :init_response, only: [:update, :set_cache]

  def all
    render json: Cache::Category.all
  end

  api :GET, '/categories', "目前已儲存的運動及聯盟項目"
  formats ['json']
  example '"/api/v1/categories"'
  example '
  {
    "unselected": [],
      "selected": [
        {
          "type": "sport",
          "id": 75,
          "name": "足球",
          "sub": [
          {
          "type": "league",
          "id": 648,
          "name": "AND",
            "sub": [
              {
                "type": "halves",
                "id": 1,
                "name": "全部"
              },
              {
                "type": "halves",
                "id": 2,
                "name": "全場"
              },
              {
                "type": "halves",
                "id": 3,
                "name": "上半場"
              },
              {
                "type": "halves",
                "id": 4,
                "name": "下半場"
              },
              {
                "type": "halves",
                "id": 5,
                "name": "特別投注"
              },
              {
                "type": "halves",
                "id": 6,
                "name": "波膽"
              },
              {
                "type": "halves",
                "id": 7,
                "name": "入球數"
              },
              {
                "type": "halves",
                "id": 8,
                "name": "半全場"
              },
              {
                "type": "halves",
                "id": 9,
                "name": "過關"
              },
              {
                "type": "halves",
                "id": 10,
                "name": "滾球"
              },
              {
                "type": "halves",
                "id": 11,
                "name": "第一節"
              },
              {
                "type": "halves",
                "id": 12,
                "name": "第二節"
              },
              {
                "type": "halves",
                "id": 13,
                "name": "第三節"
              },
              {
                "type": "halves",
                "id": 14,
                "name": "第四節"
              }
            ]
            ......
            },
            ]
          }
        ]
      }
    ]
  }
  '
  param_group :user_authentication, ::Api::V1::ApplicationController
  def index
    # raw = $redis.get("#{$redis_key_prefix}/play:categories")
    # render json: raw ? Marshal.load(raw) : []
    render json: Cache::Category.selection
  end

  api :GET, '/categories/with_matches', "目前有場次的運動及聯盟項目"
  formats ['json']
  example '"/api/v1/categories/with_matches"'
  example '
  [
    {
    "type": "sport",
    "id": 75,
      "name": "足球",
      "sub": [
        {
          "type": "league",
          "id": 651,
          "name": "AUS",
          "sub": [
            {
              "type": "halves",
              "id": 1,
              "name": "全部",
              "count": 12
            },
            {
              "type": "halves",
              "id": 2,
              "name": "全場",
              "count": 6
            },
            {
              "type": "halves",
              "id": 3,
              "name": "上半場",
              "count": 5
            },
            {
              "type": "halves",
              "id": 4,
              "name": "下半場",
              "count": 1
            }
          ],
          "count": 12
        }
      ]
      "count": 12
    }
  ]
  '
  param_group :user_authentication, ::Api::V1::ApplicationController
  def with_matches
    render json: Cache::Category.with_matches
  end

  def set_cache
    @response.message = '成功'
    @response.succeed
    cache_categories
    render json: @response
  end

  def update
    @response.message =
      if params[:name].nil?
        @response.validated
        '傳入資訊不可空白'
      elsif (category = Category.find_by(id: params[:id])).nil?
        '無此筆資料'
      else
        if category.update_attributes(display_name: params[:name])
          Cache::Category.update_cache("league", category.id, params[:name])
          @response.succeed
          '成功'
        else
          @response.data = category.errors.full_messages
          '失敗'
        end
      end
    render json: @response
  end

  private

    def init_response
      @response = Response.new
    end

    def cache_categories
      if params[:categories]
        $redis.set("#{$redis_key_prefix}/play:categories", Marshal.dump(params[:categories]))
      end
    end
end
