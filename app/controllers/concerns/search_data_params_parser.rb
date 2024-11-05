class SearchDataParamsParser < BaseSearchParamsParser
  def model_params(segments)
    form_params = existing_form_params segments, 'page'
    form_params_to_model add_defaults(form_params, 'page', 'per-page')
  end

  private

  def form_params_to_model(form_params)
    model_params = uri_keys_to_model form_params
    if model_params[:text]
      model_params[:text] = model_params[:text].split(/\s*,\s*/).map &:split
    end
    %i(from_date to_date).each do |name|
      if model_params[name]
        model_params[name] = Date.parse_utc_time model_params[name]
      end
    end
    model_params[:page] = model_params[:page].to_i
    model_params
  end

end
