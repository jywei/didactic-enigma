require 'bcrypt'

class User < ApplicationRecord

# => Relation
  has_one  :user_profile,  class_name: 'User::Profile' , inverse_of: :user
  has_one  :user_ancestor, class_name: 'User::Ancestor'
  has_many :orders
  has_many :downlines, class_name: 'User', foreign_key: :bank_id
  has_many :tokens, class_name: 'User::Token'
  has_many :settings, class_name: 'User::Setting', dependent: :destroy
  has_many :allotters, class_name: 'User::Allotter', dependent: :destroy
  belongs_to :bank, class_name: 'User', primary_key: :id, optional: true

# => Validates
  validates_uniqueness_of :username
  validates_presence_of :username, :encrypted_password
  validates_length_of :username, minimum: 4
  validates_length_of :encrypted_password, minimum: 4

# => After of Before
  after_create :create_default_setting
  accepts_nested_attributes_for :user_profile, reject_if: :all_blank

# => except
  alias_attribute :password, :encrypted_password

  def create_default_setting

    # !player? && %w(User::Allotter User::Setting).each { |model| Object.const_get(model).create_default(id) }
    User::Allotter.create_default(id) unless player?
    User::Setting.create_default(id)
  end

  def create_user(params)
    user = {
      username:             params[:username],
      encrypted_password:   params[:password],
      # email:              params[:username],
      bank_id:              id || nil,
      tier:                 id.nil? ? 0 : (self.try(:tier).to_i + 1),
      access_token:         User.generate_token,
      user_profile_attributes: {
        nickname:           params[:user_profile][:nickname],
        note:               params[:user_profile][:note],
        quota:              params[:user_profile][:quota],
        delay_original:     params[:user_profile][:delay_original],
        delay_running:      params[:user_profile][:delay_running],
        parlay:             params[:user_profile][:parlay],
        status:             params[:user_profile][:status],
        accessable:         params[:user_profile][:accessable],
        current_quota:      params[:user_profile][:quota]
      }
    }
    user[:identity] = 'assist' && user[:fork_id] = id && user[:tier] = tier.to_i if params[:identity] == 'assist'
    user = User.create(user)
    user
  end

  def line_ids
    user_ancestor.attributes.keep(*UserReport.names(:en)).values
  end

  def self.generate_token
    token      = SecureRandom.urlsafe_base64(nil, false)
    token_hash = BCrypt::Password.create(token)
    token_hash
  end

  def refresh_token
    register_outdated_token
    update(access_token: User.generate_token)
  end

  def register_outdated_token
    tokens.create!(content: access_token, reason: 'multiple_sign_in') if access_token
  end

  def info
    {
      id:           id,
      name:         username,
      identity:     identity,
      tier:         tier,
      token:        access_token,
      quota:        remaining_quota_today,
      parlay_limit: user_profile.parlay
    }
  end

  def operator?
    tier == 0
  end

  def player?
    tier == 8
  end

  def agent?
    tier == 7
  end

  def weekly_balances(params)
    today = Date.today
    [
      { name: "本週",   time: today.beginning_of_week..Date.today },
      { name: "上週",   time: today.last_week.all_week            },
      { name: "上上週", time: today.last_week.last_week.all_week  }
    ].map { |t| orders.summate_week_balances(t[:time], t[:name], params) }
  end

  def remaining_quota_today
    # total_quota * 10_000 - orders.today.sum(:amount).to_i
    profile = User::Profile.find_by(user_id: id)
    profile.current_quota * 10_000
  end

  def statistic_reports
    return {} if tier == 8
    now_time         = Time.now
    midday           = now_time.midday
    today            = now_time >= midday ? midday : midday - 1.day
    yesterday        = today.yesterday
    tomorrow         = today.tomorrow

    sports           = Sport.active
    downline_orders  = Order.where(user_id: downline_user_ids)
    settled_orders   = downline_orders.settled("true").includes(items: [:profile])
    unsettled_orders = downline_orders.settled("false").includes(items: [:profile])
    {
      code: 1,
      data: [
        Order.statistic_order(yesterday, sports, settled_orders, unsettled_orders),
        Order.statistic_order(today, sports, settled_orders, unsettled_orders),
        Order.statistic_order(tomorrow, sports, settled_orders, unsettled_orders)
      ]
    }
  end

  # 當下職位
  def title(language = :en)
    i = language == :en ? 0 : 1
    UserReport.downline_names[tier][i]
  end

  # include self
  def downline_names(language = :en)
    UserReport.tier_name(tier, language)
  end

  # exclude self
  def downline_names_below(language = :en)
    UserReport.tier_name(tier + 1, language)
  end

  def downline_users
    User::Ancestor.where("#{title} = #{id}")
  end

  def downline_user_ids
    downline_users.select{ |user| user.member !=  nil }.pluck(:user_id)
  end

  def all_downlines
    User::Ancestor.where("#{title} = ?", id).pluck(*downline_names_below).flatten.compact.uniq
  end

  # must turn target_id to integer
  def report_accessible?(target_id)
    return true if id == target_id
    all_downlines.include? target_id
  end

  # ==================
  # def downline_columns
  #   downline_tier_names.tap {|names|
  #     names.delete(:member)
  #     names << :user_id
  #   }
  # end
  #
  # def downline_tier_names
  #   UserReport.tier_name(tier + 1, :en).map(&:to_sym)
  # end
  # ==================

  # show downline info
  def downline_list(ancestor_ids)
    users = User.where(id: ancestor_ids)
    users.map do |user|
      {
          id: user.id,
        name: user.username
      }
    end
  end

  def class_to_admin
    is_admin? ? self.becomes(::Admin) : self
  end

end
