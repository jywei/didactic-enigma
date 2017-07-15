require 'test_helper'

class Api::V1::MatchesControllerIndexTest < ActionDispatch::IntegrationTest
  def setup
    @book_maker   = create(:book_maker)
    @user         = create(:user)
    @match_ba     = create(:match, :full, :with_book_maker, :with_offers, :with_team, :with_category, :with_group, match_category: :basketball)
    @match_bb     = create(:match, :full, :with_book_maker, :with_offers, :with_team, :with_category, :with_group, match_category: :baseball)
    @match_nba    = create(:match, :full, :with_book_maker, :with_offers, :with_team, :with_category, :with_group, match_category: :nba, leader_id: 555)
    @match_nba_ht = create(:match, :ht,   :with_book_maker, :with_offers, :with_team, :with_category, :with_group, match_category: :nba, leader_id: 555)
    @match_nba_hf = create(:match, :hf,   :with_book_maker, :with_offers, :with_team, :with_category, :with_group, match_category: :nba, leader_id: 555)
    @match_another_nba = create(:match, :full, :with_book_maker, :with_offers, :with_team, :with_category, :with_group, match_category: :nba, leader_id: 556)
    @match_nba_no_offer = create(:match, :ht, :with_book_maker, :with_team, :with_category, :with_group, match_category: :nba, leader_id: 556)
    @category_nba = @match_nba.category
    @sport_ba     = @match_ba.category.sport
    @sport_bb     = @match_bb.category.sport
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

  def offers_include?(name)
    offers.map { |offer| offer['en'] }.include?(name)
  end

  def find_match(match)
    matches[match.key]
  end

  def basic_params
    {
      # token: @user.access_token
    }
  end

  def test_match_with_no_offer_will_not_render
    get '/api/v1/matches'
    assert find_match(@match_another_nba)
    refute find_match(@match_nba_no_offer)
  end

  def test_index_no_type
    get '/api/v1/matches'
    refute find_match(@match_ba)
    assert find_match(@match_nba_ht)
    assert find_match(@match_nba)
    assert offers_include? 'point'
    refute offers_include? 'three_way'
  end

  def test_index_data_book_maker
    get '/api/v1/matches', params: basic_params.merge(league_id: @category_nba.id, type_id: 1)
    assert_equal @book_maker.name, find_match(@match_nba)['book_maker']
  end

  def test_index_data_halves_name
    get '/api/v1/matches', params: basic_params.merge(league_id: @category_nba.id, type_id: 1)
    en = find_match(@match_nba)['halves']['en']
    ch = Info::OddCategory.to_ch(en)
    assert_equal ch, Info::OddCategory.to_en(ch)
  end

  # def test_index_nba_indexing_halves
  #   get '/api/v1/matches', params: basic_params.merge(league_id: @category_nba.id, type_id: 1)
  #   assert find_match(@match_nba)
  #   assert find_match(@match_nba_ht)
  #   assert find_match(@match_nba_hf)
  #   assert find_match(@match_another_nba)
  #   assert_equal 0, find_match(@match_nba)['halves']['index']
  #   assert_equal 1, find_match(@match_nba_ht)['halves']['index']
  #   assert_equal 2, find_match(@match_nba_hf)['halves']['index']
  #   assert_equal 0, find_match(@match_another_nba)['halves']['index']
  # end

  def test_index_nba_full
    get '/api/v1/matches', params: basic_params.merge(league_id: @category_nba.id, type_id: 2)
    assert_nil   find_match(@match_ba)
    assert_nil   find_match(@match_nba_ht)
    assert_equal find_match(@match_nba)['match_id'], @match_nba.to_open[:match_id]
    assert     offers_include? 'ml'
    refute     offers_include? 'three_way'
  end

  def test_index_nba_ht
    get '/api/v1/matches', params: basic_params.merge(league_id: @category_nba.id, type_id: 3)
    assert_nil   find_match(@match_ba)
    assert_nil   find_match(@match_nba)
    assert_equal find_match(@match_nba_ht)['match_id'], @match_nba_ht.to_open[:match_id]
    assert     offers_include? 'ml'
    refute     offers_include? 'three_way'
  end

  def test_index_nba_all
    get '/api/v1/matches', params: basic_params.merge(league_id: @category_nba.id, type_id: 1)
    assert_nil find_match(@match_ba)
    assert     find_match(@match_nba)
    assert     find_match(@match_nba_ht)
  end

  def test_index_basketball
    get '/api/v1/matches', params: basic_params.merge(sport_id: @sport_ba.leader_spid, type_id: 2)
    match = find_match(@match_ba)
    assert_equal match['match_id'],     @match_ba.to_open[:match_id]
    assert_equal match['match_number'], @match_ba.to_open[:match_number]
    assert     offers_include? 'ml'
    refute     offers_include? 'three_way'
  end

  def test_index_baseball
    get '/api/v1/matches', params: basic_params.merge(sport_id: @sport_bb.leader_spid, type_id: 2)
    match = find_match(@match_bb)
    assert_equal match.try(:[], 'match_id'),     @match_bb.to_open.key
    assert_equal match.try(:[], 'match_number'), @match_bb.to_open[:match_number]
    assert     offers_include? 'ml'
    refute     offers_include? 'three_way'
  end

  def test_index_parlay_present
    get '/api/v1/matches', params: basic_params.merge(league_id: @category_nba.id, type_id: 2, parlay: true)
    assert     find_match(@match_nba)['play']
  end
end
