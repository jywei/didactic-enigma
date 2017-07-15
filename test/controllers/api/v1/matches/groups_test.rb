require 'test_helper'

class Api::V1::MatchesControllerGroupsTest < ActionDispatch::IntegrationTest
  def setup
    @book_maker        = create(:book_maker)
    @user              = create(:user)
    @match_ba          = create(:match, :full, :with_book_maker, :with_offers, :with_team, :with_category, :with_group, match_category: :basketball)
    @match_bb          = create(:match, :full, :with_book_maker, :with_offers, :with_team, :with_category, :with_group, match_category: :baseball)
    @match_nba         = create(:match, :full, :with_book_maker, :with_offers, :with_team, :with_category, :with_group, match_category: :nba, leader_id: 555, h_stake: Faker::Number.number(6))
    @match_nba_ht      = create(:match, :ht,   :with_book_maker, :with_offers, :with_team, :with_category, :with_group, match_category: :nba, leader_id: 555, h_stake: Faker::Number.number(6))
    @match_nba_hf      = create(:match, :hf,   :with_book_maker, :with_offers, :with_team, :with_category, :with_group, match_category: :nba, leader_id: 555, h_stake: Faker::Number.number(6))
    @match_another_nba = create(:match, :full, :with_book_maker, :with_offers, :with_team, :with_category, :with_group, match_category: :nba, leader_id: 556, h_stake: Faker::Number.number(6))
    @category_nba      = @match_nba.category
    @sport_ba          = @match_ba.category.sport
    @sport_bb          = @match_bb.category.sport
    Category.save_current
    Match.with_data.active.open!
  end

  def matches
    return @matches if @matches
    res = JSON.parse(@response.body)
    @matches = res['matches']
  end

  def offers
    return @offers if @offers
    res = JSON.parse(@response.body)
    @offers = res['offers']
  end

  def groups
    return @groups if @groups
    res = JSON.parse(@response.body)
    @offers = res['groups']
  end

  def get_matches
    get '/api/v1/matches/groups'
  end

  def get_player_matches
    get '/api/v1/matches/player_groups'
  end

  def find_match(match)
    matches[match.match_id]
  end

  def find_halves_match(match)
    m = find_match(match)
    if m
      m['halves_matches'][match.key]
    else
      raise "group not found with #{match.halves_match_id}"
    end
  end

  def nba_stake_sum(team)
    [@match_nba, @match_nba_ht, @match_nba_hf].reduce(0) do |result, match|
      result + match.send(:"#{team}_stake")
    end
  end

  def test_matches
    get_matches
    assert matches.any?
  end

  def test_matches_include_nba
    get_matches
    assert       find_match(@match_nba)
    assert       find_match(@match_nba_ht)
    assert       find_match(@match_nba_hf)
    assert       matches[@match_nba.match_id]['start_time']
    assert_equal 'BA', matches[@match_nba.match_id]['sport']
    assert       find_halves_match(@match_nba)
    assert       find_halves_match(@match_nba_ht)
    assert       find_halves_match(@match_nba_hf)
  end

  def test_add_stakes
    get_matches
    assert_equal nba_stake_sum(:h), find_match(@match_nba)['h_stake']
  end

  def test_offers
    get_matches
    assert matches.any?
  end

  def test_match_not_disabled
    get_matches
    refute find_match(@match_nba)[:disabled]
  end

  def test_match_disabled
    [@match_nba, @match_nba_ht, @match_nba_hf].each do |match|
      afu = match.afu
      afu[:stat] = 'disabled'
      afu.save!
    end

    get_matches
    assert find_match(@match_nba)['disabled']
  end

  def test_groups_format
    get_matches
    assert_includes groups.to_s, @match_nba.group.id.to_s
    assert_includes groups.to_s, @match_nba.group.display_name
  end

  def test_match_includes_group_id
    get_matches
    assert matches.first[1]["group_id"]
  end

  def test_player_matches_without_modifier
    get_player_matches
    refute_includes matches.to_s, "h_modifier"
    refute_includes matches.to_s, "modifier"
  end

  def test_matches_with_modifier
    get_matches
    assert_includes matches.to_s, "h_modifier"
    assert_includes matches.to_s, "h_base"
    assert_includes matches.to_s, "base_proportion"
    assert_includes matches.to_s, "modifier"
    assert_includes matches.to_s, "proportion"
  end
end
