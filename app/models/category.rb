# Category 儲存所有國家或聯盟的項目，稱為種類
class Category < ApplicationRecord

# => Relation
  has_many :groups
  has_many :matches
  accepts_nested_attributes_for :matches
  belongs_to :sport, primary_key: :leader_spid, foreign_key: :spid

# => Validates
  validates_uniqueness_of :mgid
  validates_presence_of :name

# =>  Scope
  scope :less_matches, -> { joins( :matches ).group( 'category_id' ).where( 'count( leader_id ) > ? AND active = ?', 10, true ) }


  # 取得運動+種類的縮寫
  def league_name
    "#{slug}#{name}"
  end

  # 取得運動+種類的中文名稱
  def league_ch
    "#{sport.display_name}#{name}"
  end

  # 取得目前所有運動的種類ID列表
  def self.current
    {
      'soccer'         => where(slug: 'FB').ids.join(','),
      'basketball_nba' => where(slug: 'BA', name: 'NBA').first&.id.to_s,
      'basketball'     => where(slug: 'BA').where.not(name: 'NBA').ids.join(','),
      'baseball_mlb'   => where(slug: 'BB', name: 'MLB').first&.id.to_s,
      'baseball_jpn'   => where(slug: 'BB', name: 'JPN').first&.id.to_s,
      'baseball_chn'   => where(slug: 'BB', name: 'CHN').first&.id.to_s,
      'baseball'       => where(slug: 'BB').where.not(name: %w(MLB JPN CHN)).ids.join(','),
      'ice_hockey'     => where(slug: 'IC').ids.join(','),
      'tennis'         => where(sport: 'tennis').ids.join(','),
      'test'           => where(sport: Sport.find_or_create_by(name: 'test', leader_spid: 8888)).ids.join(',')
    }
  end

  # 將 #current 的結果儲存至redis相對應的key
  def self.save_current
    current.each do |category_name, ids|
      $redis.db.hset($categories_key, category_name, ids)
    end
  end

  # 取得目前所有運動底下的玩法有哪些
  def self.offers
    soccer = Info::OddType.ch.map { |k, v| { 'en' => k, 'ch' => v } unless k == 'ml' }.compact
    others = Info::OddType.ch.map { |k, v| { 'en' => k, 'ch' => v } unless k == 'three_way' }.compact
    {
      'soccer'         => soccer,
      'basketball_nba' => others,
      'basketball'     => others,
      'baseball_mlb'   => others,
      'baseball_jpn'   => others,
      'baseball_chn'   => others,
      'baseball'       => others,
      'ice_hockey'     => others,
      'tennis'         => others,
      'test'           => others
    }
  end

  # 檢查這個種類是否為足球
  def soccer?
    sport.try(:name) == 'soccer'
  end

  # 檢查這個種類是否為測試項目
  def test?
    sport.try(:name) == 'test'
  end

  # 檢查這個種類是否有三路玩法
  def has_three_way?
    soccer? || test?
  end

  # 檢查這個種類是否有獨贏玩法
  def has_ml?
    has_three_way?.!
  end

  # 檢查這個種類是否有平手賭金
  def d_stake?
    has_three_way?
  end

  # 回傳玩法類別ID列表
  #
  # ```ruby
  # [
  #  {:type=>"halves", :id=>1, :name=>"全部"},
  #  {:type=>"halves", :id=>2, :name=>"全場"},
  #  {:type=>"halves", :id=>3, :name=>"上半場"},
  #  {:type=>"halves", :id=>4, :name=>"下半場"},
  #  {:type=>"halves", :id=>5, :name=>"特別投注"},
  #  {:type=>"halves", :id=>6, :name=>"波膽"},
  #  {:type=>"halves", :id=>7, :name=>"入球數"},
  #  {:type=>"halves", :id=>8, :name=>"半全場"},
  #  {:type=>"halves", :id=>9, :name=>"過關"},
  #  {:type=>"halves", :id=>10, :name=>"滾球"},
  #  {:type=>"halves", :id=>11, :name=>"第一節"},
  #  {:type=>"halves", :id=>12, :name=>"第二節"},
  #  {:type=>"halves", :id=>13, :name=>"第三節"},
  #  {:type=>"halves", :id=>14, :name=>"第四節"}
  # ]
  # ```
  def ot
    Info::OddCategory.array(self)
  end
end
