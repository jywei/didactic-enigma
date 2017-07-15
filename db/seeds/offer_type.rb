
#自定義offer_type 與tx不一樣
puts 'Offer::Type seeds importing...'
if Offer::Type.all.count > 19
  puts 'Offer::Type has allready create!'
else
  Offer::Type.transaction do
    ot_default =  [
                    [1,  "point",                 "point",     false, false, "讓球"],
                    [2,  "ou",                    "ou",        false, false, "大小"],
                    [3,  "ml",                    "ml",        false, false, "獨贏"],
                    [4,  "odd_even",              "odd_even",  false, false, "單雙"],
                    [5,  "running_point",         "point",     true, false,  "走地讓球"],
                    [6,  "running_ou",            "ou",        true, false,  "走地大小"],
                    [7,  "correct_score",         nil,         false, false, "波膽"],
                    [8,  "total_scores",          nil,         false, false, "總入球"],
                    [9,  "full_half",             nil,         false, false, "全半場"],
                    [10, "parlay_point",          nil,         false, false, "讓分過關"],  # temporary false
                    [11, "parlay_complex",        nil,         false, true,  "綜合過關"],
                    [12, "parlay_standard",       nil,         false, false, "標準過關"],  # temporary false
                    [13, "all",                   nil,         false, false, "全部"],
                    [14, "running_odd_even",      "odd_even",  true, false,  "走地單雙"],
                    [15, "one_win",               "one_win",   false, false, "一輸二贏"],
                    [16, "three_way",             "three_way", false, false, "三路"],
                    [17, "running_ml",            "ml",        true, false,  "走地獨贏"],
                    [18, "running_correct_score", nil,         true, false,  "走地波膽"],
                    [19, "running_three_way",     "three_way", true, false,  "走地三路"],
                    [20, "running_one_win",       "one_win",   true, false,  "走地一輸二贏"]
                  ]
    ot_default.each do |ot|
      Offer::Type.create(id: ot[0], name: ot[1], offer_name: ot[2], running: ot[3], parlay: ot[4], name_ch: ot[5])
    end
  end
end