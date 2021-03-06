require 'feature_helper'
require 'api_test_helper'
require 'models/session_proxy'

RSpec.describe 'user sends authn requests' do
  let(:api_saml_endpoint) { api_uri('session') }

  context 'and it is received successfully' do
    let(:session_start_time) { current_time_in_millis }
    it 'will redirect the user to /start' do
      stub_federation
      stub_api_saml_endpoint

      visit('/test-saml')
      click_button 'saml-post'

      expect(page).to have_title 'Start - GOV.UK Verify - GOV.UK'

      expect(page.get_rack_session['transaction_simple_id']).to eql 'test-rp'
      expect(cookie_value(CookieNames::SECURE_COOKIE_NAME)).not_to be_empty

      cookies = Capybara.current_session.driver.request.cookies
      expected_cookies = CookieNames.session_cookies + ['_verify-frontend_session', CookieNames::VERIFY_FRONT_JOURNEY_HINT]

      expect(cookies.keys.to_set).to eql expected_cookies.to_set
    end

    it 'will redirect the user to /confirm-your-identity when journey hint is set' do
      set_journey_hint_cookie('http://idcorp.com')
      stub_federation
      stub_api_saml_endpoint
      visit('/test-saml')
      click_button 'saml-post-journey-hint'
      expect(page).to have_title 'Confirm your identity - GOV.UK Verify - GOV.UK'
    end

    it 'will redirect the user to the Welsh /confirm-your-identity when journey hint has a Welsh locale set' do
      set_journey_hint_cookie('http://idcorp.com', 'cy')
      stub_federation
      stub_api_saml_endpoint
      visit('/test-saml')
      click_button 'saml-post-journey-hint'
      expect(page).to have_title 'Cadarnhau eich hunaniaeth - GOV.UK Verify - GOV.UK'
      expect(page).to have_css 'html[lang=cy]'
    end
  end

  context 'and it is not received successfully' do
    it 'will render the something went wrong page' do
      allow(Rails.logger).to receive(:error)
      expect(Rails.logger).to receive(:error).with(kind_of(Api::Error)).at_least(:once)
      stub_request(:post, api_saml_endpoint).to_return(body: '{"message": "error"}', status: 500)
      stub_transactions_list
      visit('/test-saml')
      click_button 'saml-post'
      expect(page).to have_content 'Sorry, something went wrong'
    end
  end
end
