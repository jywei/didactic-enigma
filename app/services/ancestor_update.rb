module AncestorUpdate
  def update_ancestors(user)
    ancestor_arr = find_upperline(user)
    user_ancestor = {
      admin:             ancestor_arr[0],
      moderator:         ancestor_arr[1],
      supervisor:        ancestor_arr[2],
      director:          ancestor_arr[3],
      major_shareholder: ancestor_arr[4],
      shareholder:       ancestor_arr[5],
      general_agent:     ancestor_arr[6],
      agent:             ancestor_arr[7],
      member:            ancestor_arr[8],
      user_id:           user.id
    }
    ::User::Ancestor.create(user_ancestor)
  end

  def find_upperline(user)
    user.tier.eql?(0) ? [user.id] : find_upperline(::User.find(user.bank_id)).push(user.id)
  end
end
