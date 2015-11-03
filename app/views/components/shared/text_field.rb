module Components
  class TextField

    include React::Component

    required_param :record
    required_param :field_name
    optional_param :password, default: nil
    optional_param :credit_card, default: nil
    optional_param :on_change, type: Proc
    optional_param :clear_base_errors, default: true
    optional_param :on_enter, type: Proc
    optional_param :html_options, default: {}

    backtrace :on

    def nib(value) # nil if blank
      value == "" ? nil : value
    end

    def render
      div do
        value = "#{record.send(field_name)}"
        if credit_card
          value = if value[0] == "3"
            [nib(value[0..3]), nib(value[4..9]), nib(value[10..14])]
          else
            [nib(value[0..3]), nib(value[4..7]), nib(value[8..11]), nib(value[12..15])]
          end.compact.join("-")
        end
        input(html_options).form_control(
          name: "#{record.class.to_s}[#{field_name}]",
          type: password ? 'password' : 'text',
          class: "#{'input-error' if record.errors[field_name]}",
          # placeholder_or_value_key => "#{record.send(field_name) unless password}"
          value: value
        ).on(:change) do |e|
          value = e.target.value
          if credit_card
            value = value[0..-2] if value[-1] == "-"
            value = value.gsub("-","")
          end
          record.send("#{field_name}=", value)
          force_update! unless record.attributes.has_key? field_name
          on_change
          record.errors.delete(field_name)
          record.errors.delete(:base) if clear_base_errors
        end.on(:key_down) do |e|
          on_enter if e.key_code == 13
        end
        p.text_center.medium_weight.text_danger { "#{record.errors[field_name]}" } if record.errors[field_name]
      end
    end

  end
end
