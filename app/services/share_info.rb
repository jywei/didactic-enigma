module ShareInfo
  def ancestor_shares(user_id, sport_name)
    ancestorz_arr = User::Ancestor.member.upperlines(user_id).attributes.values[1..-1]
    oppos = User::Allotter.where("name = ? AND user_id in (?)", sport_name, ancestorz_arr).order(user_id: :desc).pluck(:oppo).map(&:to_f)
    oppos
  end

  def share_interval(oppos)
    tmp = []
    while(oppos.length != 1)
      tmp << oppos[0].to_f if oppos.length == 8
      tmp << (oppos[1].to_f - oppos[0].to_f).round(3)
      oppos.shift
    end
    tmp.reverse
  end

  def share_cut(stake, shares)
    {
      admin:              stake * shares[0],
      moderator:          stake * shares[1],
      supervisor:         stake * shares[2],
      director:           stake * shares[3],
      major_shareholder:  stake * shares[4],
      shareholder:        stake * shares[5],
      general_agent:      stake * shares[6],
      agent:              stake * shares[7],
      member:             stake
    }
  end

  # module_function :ancestor_shares
end
