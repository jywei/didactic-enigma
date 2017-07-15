require 'test_helper'

class Cache::CategoryTest < ActiveSupport::TestCase
  def setup
    @baseball = create(:sport, :baseball)
    @nba      = create(:category, :nba)
    @mlb      = create(:category, :mlb)
    @jpn      = create(:category, :bbjpn)
    create(:match, :with_offers, :with_team, :with_book_maker, :with_group, category: @mlb, halves: 'full').open!
    create(:match, :with_offers, :with_team, :with_book_maker, :with_group, category: @nba, halves: 'hf').open!

    $redis.set("#{$redis_key_prefix}/play:categories", Marshal.dump(
      {
        unselected: [],
        selected: [

          {
            type: 'sport',
            id: @baseball.id,
            name: @baseball.name,
            sub: [
              {
                type: 'league',
                id: @mlb.id,
                name: @mlb.name,
                sub: halves
              },
              {
                type: 'league',
                id: @jpn.id,
                name: @jpn.name,
                sub: halves
              }
            ]
          },
          {
            type: 'league',
            id: @nba.id,
            name: @nba.name,
            sub: halves
          }

        ]
      }.with_indifferent_access
    ))
  end

  def halves
    [
      {
        type: 'halves',
        id: 1,
        name: '全部'
      },
      {
        type: 'halves',
        id: 2,
        name: '全場'
      },
      {
        type: 'halves',
        id: 3,
        name: '上半場'
      },
      {
        type: 'halves',
        id: 4,
        name: '下半場'
      }
    ]
  end

  def baseball
    only_matches.select{ |n| n['name'] == 'baseball' }.first
  end

  def mlb(halves = nil)
    match = baseball['sub'].select{ |n| n['name'] == 'MLB' }.first
    if halves.nil?
      match
    else
      match['sub'].select{ |n| n['name'] == halves }.first
    end
  end

  def nba(halves = nil)
    match = only_matches.select{ |n| n['name'] == 'NBA' }.first
    if halves.nil?
      match
    else
      match['sub'].select{ |n| n['name'] == halves }.first
    end
  end

  def jpn
    only_matches.select{ |n| n['name'] == 'JPN' }.first
  end

  def only_matches
    Cache::Category.with_matches
  end

  def test_with_matches_mlb
    assert baseball
    assert mlb
    assert mlb('全部')
    assert mlb('全場')
    refute mlb('上半場')
  end

  def test_with_matches_jpn
    refute jpn
  end

  def test_with_matches_nba
    assert nba
    assert nba('全部')
    refute nba('全場')
    assert nba('下半場')
  end
end
