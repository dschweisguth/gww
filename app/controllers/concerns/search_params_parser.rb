class SearchParamsParser < BaseSearchParamsParser
  def form_params(segments)
    add_defaults existing_form_params(segments)
  end
end
