module MocksHelper
  def time_format(time)
    time.strftime("%m/%d %H:%M:%S")
  end

  def in_current_offer_ids(id)
    "current-offer" if @current_offer_ids && id.to_i.in?(@current_offer_ids) 
  end

  def display_head(offer)
    v = offer
    if v["asian_new"]
      prob = if v[:handicapped][:proportion] >= 0
               "+#{v[:handicapped][:proportion]}"
             else
               v[:handicapped][:proportion].to_s
             end
      "#{v[:handicapped][:head]} #{prob}"
    else
      v[:handicapped][:head]
    end
  end

  def column(title, id, options = {})
    input_type = case options[:type]
                 when 'number', 'float'
                   :number_field_tag
                 else
                   :text_field_tag
                 end

    content_tag(
      :div,
      content_tag(
        :div, 
        content_tag(
          :p, 
          title, 
          class: 'form-title'
        ), 
        class: "col-sm-2"
      ) +
      content_tag(
        :div, 
        send(
          input_type,
          id, 
          options[:default] || "", 
          class: 'form-control', placeholder: options[:placeholder] || "", step: (options[:type] == "float" ? "0.01" : "1")
        ), 
        class: "col-sm-4"
      ),
      class: "col-sm-12"
    )
  end
end
