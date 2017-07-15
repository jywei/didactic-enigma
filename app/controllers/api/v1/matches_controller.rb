class Api::V1::MatchesController < Api::V1::ApplicationController
  skip_before_action :verify_token
  include Api::V1::MatchesHelper

  def index
    params[:action] = :list
    render json: Match::Open.query_by(params)
  end

  api :GET, '/matches/groups', "比賽場次列表"
  param :sport_id, String, "運動種類ID"
  param :league_id, String, "種類ID"
  param :type_id, String, "場次種類ID"
  formats ['json']
  example '"/api/v1/matches/groups?league_id=716&type_id=1"'
  example '
  {
    "matches": {
      "381915159": {
      "start_time": "2016/12/26 09:00",
      "start_time_int": 1482714000,
        "sport": "BA",
        "team": {
          "home": [
            812323,
            "OklahomaCityThunder"
          ],
          "away": [
            812304,
            "明尼蘇達木狼"
          ]
        },
        "h_score": 0,
        "a_score": 0,
        "h_stake": 0,
        "a_stake": 0,
        "d_stake": null,
        "match_result": null,
        "is_running": false,
        "book_maker": "PinnacleSports",
        "group_id": 1,
        "match_id": "381915159",
        "halves_matches": {
          "12260900_3819151_59_0": {
            "match_id": "12260900_3819151_59_0",
            "_halves_match_id": "12260900_3819151_59_0",
            "match_number": "BA181012",
            "halves": {
              "id": 2,
              "slug": "full",
              "name": "全場"
            },
            "play": {
              "ou": {
                "type": "ou",
                "type_ch": "大小",
                "head": "h",
                "asian": true,
                "has_head": true,
                "asian_new": false,
                "is_parlay": false,
                "handicapped": {
                  "head": 211.5,
                  "proportion": 0,
                  "modifier": 0
                },
                "stat": "normal",
                "offer_id": 983434,
                "water": "0.015",
                "running_water": "0.02",
                "is_running": false,
                "index": 1,
                "h": 0.953,
                "a": 0.969,
                "h_modifier": 0,
                "a_modifier": 0,
                "positions": {
                  "h": 0,
                  "a": 0
                },
                "thresholds": {
                  "h": -2000000,
                  "a": -2000000
                },
                "distances": {
                  "h": 0,
                  "a": 0
                },
                "wager": {
                  "h": 0,
                  "a": 0
                },
                "last_updated": {
                  "h": 1484732620748,
                  "a": 1484732620752,
                  "asian": 1484732620752,
                  "push": "2017-01-18 17:43:40"
                },
                "series": true,
                "h_stake": 0,
                "a_stake": 0,
                "d_stake": 0
              },
              "point": {
                "type": "point",
                "type_ch": "讓分",
                "head": "h",
                "asian": true,
                "has_head": true,
                "asian_new": false,
                "is_parlay": false,
                "handicapped": {
                "head": 11.5,
                "proportion": 0,
                "modifier": 0
                },
                "stat": "normal",
                "offer_id": 983352,
                "water": "0.015",
                "running_water": "0.02",
                "is_running": false,
                "index": 0,
                "h": 0.961,
                "a": 0.961,
                "h_modifier": 0,
                "a_modifier": 0,
                "positions": {
                  "h": 0,
                  "a": 0
                },
                "thresholds": {
                  "h": -2_000_000,
                  "a": -2_000_000
                },
                "distances": {
                  "h": 0,
                  "a": 0
                },
                "wager": {
                  "h": 0,
                  "a": 0
                },
                "last_updated": {
                  "h": 1484732620767,
                  "a": 1484732620767,
                  "asian": 1484732620767,
                  "push": "2017-01-18 17:43:40"
                },
                "series": true,
                "h_stake": 0,
                "a_stake": 0,
                "d_stake": 0
              },
              "ml": {
                "type": "ml",
                "type_ch": "獨贏",
                "head": "h",
                "asian": false,
                "has_head": false,
                "asian_new": false,
                "is_parlay": false,
                "handicapped": {
                  "head": 0,
                  "proportion": 0,
                  "modifier": 0
                },
                "stat": "unavailable",
                "offer_id": null,
                "water": "0.0",
                "running_water": "0.02",
                "is_running": false,
                "index": 2,
                "h": 0,
                "a": 0,
                "h_modifier": 0,
                "a_modifier": 0,
                "positions": {
                  "h": 0,
                  "a": 0
                },
                "thresholds": {
                  "h": -2_000_000,
                  "a": -2_000_000
                },
                "distances": {
                  "h": 0,
                  "a": 0
                },
                "wager": {
                  "h": 0,
                  "a": 0
                },
                "last_updated": {
                  "h": 1484732620902,
                  "a": 1484732620902,
                  "asian": 1484732620902,
                  "push": "2017-01-18 17:43:40"
                },
                "series": true,
                "h_stake": 0,
                "a_stake": 0,
                "d_stake": 0
              },
              "one_win": {
                "type": "one_win",
                "type_ch": "一輸二贏",
                "head": "h",
                "asian": false,
                "has_head": false,
                "asian_new": false,
                "is_parlay": false,
                "handicapped": {
                  "head": 0,
                  "proportion": 0,
                  "modifier": 0
                },
                "stat": "unavailable",
                "offer_id": null,
                "water": "0.0",
                "running_water": "0.02",
                "is_running": false,
                "index": 3,
                "h": 0,
                "a": 0,
                "h_modifier": 0,
                "a_modifier": 0,
                "positions": {
                  "h": 0,
                  "a": 0
                },
                "thresholds": {
                  "h": -2000000,
                  "a": -2000000
                },
                "distances": {
                  "h": 0,
                  "a": 0
                },
                "wager": {
                  "h": 0,
                  "a": 0
                },
                "last_updated": {
                  "h": 1484732620910,
                  "a": 1484732620910,
                  "asian": 1484732620910,
                  "push": "2017-01-18 17:43:40"
                },
                "series": true,
                "h_stake": 0,
                "a_stake": 0,
                "d_stake": 0
              },
              "odd_even": {
                "type": "odd_even",
                "type_ch": "單雙",
                "head": "h",
                "asian": false,
                "has_head": false,
                "asian_new": false,
                "is_parlay": false,
                "handicapped": {
                  "head": 0,
                  "proportion": 0,
                  "modifier": 0
                },
                "stat": "unavailable",
                "offer_id": null,
                "water": "0.0",
                "running_water": "0.02",
                "is_running": false,
                "index": 4,
                "h": 0,
                "a": 0,
                "h_modifier": 0,
                "a_modifier": 0,
                "positions": {
                  "h": 0,
                  "a": 0
                },
                "thresholds": {
                  "h": -2000000,
                  "a": -2000000
                },
                "distances": {
                  "h": 0,
                  "a": 0
                },
                "wager": {
                  "h": 0,
                  "a": 0
                },
                "last_updated": {
                  "h": 1484732620911,
                  "a": 1484732620911,
                  "asian": 1484732620911,
                  "push": "2017-01-18 17:43:40"
                },
                "series": true,
                "h_stake": 0,
                "a_stake": 0,
                "d_stake": 0
              }
            },
            "h_stake": 0,
            "a_stake": 0,
            "h_score": 0,
            "a_score": 0,
            "stat": "normal"
          }
        },
        "disabled": false
      }
      }
    },
    "groups": {
      "1": "美國職業籃球聯賽"
    },
    "offers": [
      {
        "en": "point",
        "ch": "讓分"
      },
      {
        "en": "ou",
        "ch": "大小"
      },
      {
        "en": "ml",
        "ch": "獨贏"
      },
      {
        "en": "one_win",
        "ch": "一輸二贏"
      },
      {
        "en": "odd_even",
        "ch": "單雙"
      }
    ]
  }
  '
  param_group :user_authentication, ::Api::V1::ApplicationController
  def groups
    params[:action] = :group
    render json: Match::Open.query_by(params)
  end

  api :GET, '/matches/player_groups', "遊戲端比賽場次列表"
  def player_groups
    params[:action] = :group_player
    render json: Match::Open.query_by(params)
  end

  def test_exception
    params[:foo] = "bar"
    raise "This is a test error"
  end
end
