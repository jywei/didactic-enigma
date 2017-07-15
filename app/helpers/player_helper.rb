module PlayerHelper
  @@sports = { "1" => "足球", "2" => "冰球", "3" => "籃球", "4" => "橄欖球", "5" => "網球", "6" => "美式足球", "7" => "棒球", "888" => "測試" }

  def sport_name(id)
    @@sports[id.to_s]
  end
end
