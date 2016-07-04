class FurtherInformationService
  def initialize(session_proxy, attribute_display_data_repo)
    @session_proxy = session_proxy
    @attribute_display_data_repo = attribute_display_data_repo
  end

  def fetch(cookies)
    attribute_key = @session_proxy.cycle_three_attribute_name(cookies)
    @attribute_display_data_repo.fetch(attribute_key.downcase)
  end
end