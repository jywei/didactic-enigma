class Admin < User
  has_many :admin_roles, dependent: :destroy
  has_many :roles, :through => :admin_roles, foreign_key: "role_id", dependent: :destroy

  undef :orders, :user_ancestor, :user_profile, :downlines, :downline_ids, :downline_list, :downline_users,
        :downline_user_ids, :downline_names, :downline_names_below, :bank, :title

  class << self
    def all
      super.where(is_admin: true)
    end

    def create(*argv)
      argv[0][:is_admin] = true
      user = User.create(argv)
      user.first.class_to_admin
    end

    def all_admin_profile
      profile = []
      Admin.all.each do |admin|
        profile << admin.profile
      end
      profile
    end
  end

  def info
    {
      id:       id,
      name:     username,
      identity: identity,
      token:    access_token,
      is_admin: is_admin
    }
  end

  def profile
    {
      id:              id,
      username:        username,
      sign_in_count:   sign_in_count,
      last_sign_in_at: last_sign_in_at,
      last_sign_in_ip: last_sign_in_ip,
      created_at:      created_at
    }
  end

  def check_competence(class_name, action)
    all_competence.include? [class_name, action]
  end

  def all_competence
    roles.pluck(:controller, :action)
  end

  def add_role(role_id)
    admin_roles.find_or_create_by(role_id: role_id)
  end

  def remove_role(role_id)
    admin_roles.find_by(role_id: role_id).destroy
  end

end
