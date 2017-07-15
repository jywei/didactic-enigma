require 'json'
# require "base64"
module Pushes::Matches::LogsHelper
  def link_to_log(log)
    if @show
      log.id
    else
      link_to log.id, "/pushes/matches/#{params[:id]}/logs/#{log.id}"
    end
  end

  def break_line_message(line)
      cut(line)
  end


  def cache_worker_get_offer_id(line = 'Running job with option: {"Valid"=>true, "action"=>"replace_offer", "offer_id"=>10564, "offer_name"=>""')
      begin
        if line.to_s.include?("Running job with option")
          offer_id = line.to_s[/(offer_id\"\=\>)[\d]*/][/[0-9]+/]  
          offer_id.to_s
        else
          ''
        end
      rescue Exception => e
        puts e
        ''
      end
  end

  def get_json(line)
    line = cut(line)
    if line.include?("[更動前的Match]") || line.include?("[更動後的Match]")
      line = line.gsub('[更動前的Match] ','')
      line = line.gsub('[更動後的Match] ','')
      line = line.gsub('[更動後的Match] ','')
      line = line.gsub('#<','"')
      line = line.gsub('>,','",')
      line = line.gsub('nil','"nil"')
      line = line.gsub('true','"true"')
      line = line.gsub('false','"false"')
      eval(line).to_json
      # line
    else
      false
    end
  end


  def cut(string)
    string[0..8].gsub('- ','')+string[9..-1]
  end

  def break_line(line)
    limit = 150
    if line.size > limit
      result = []
      times = line.size / limit + 1
      times.times do |n|
        start_point = 0 + n * limit
        end_point   = start_point + limit
        style       = n == 0 ? "" : "margin-left: 10px;"
        result << content_tag(:p, line[start_point...end_point], style: style)
      end
      result.join("").html_safe
    else
      content_tag :p, line
    end
  end
end
