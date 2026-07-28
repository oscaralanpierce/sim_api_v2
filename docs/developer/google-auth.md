# Google Auth

Skyrim Inventory Management handles authentication and authorization exclusively through Google. On the back end, API requests are authenticated in the `ApplicationController` by the `ApplicationController::AuthorizationService`. If authorization succeeds and a matching user is able to be found or created in the database, that user is set as `current_user` in the controller for that request and is then able to access their own resources.

The actual login flow takes place on the front end. When the front end sends a request with an `Authorization` header, the bearer token is decoded as a JWT using Google's public key as described in the [Firebase docs](https://firebase.google.com/docs/auth/admin/verify-id-tokens#web). Since there is no Firebase SDK for Ruby, this is done using Faraday to fetch public keys and the Ruby `jwt` library to decode the token. Unlike previous versions of Google authentication, which involved an API call to Google to verify token validity and retrieve profile data, now all profile data is present on the JWT sent with the `Authorization` header.

## Authenticating in RSpec

Most RSpec tests, including specs for controller services, don't require an authenticated user. You should only need an authenticated user for request specs.

The [`AuthHelper` module](/spec/support/auth_helper.rb) is included in the `rails_helper` to provide methods to do this cleanly. These methods are designed to be used with the `:authenticated_user` and `:authenticated_user_with_playthroughs` factories to seamlessly incorporate auth into any request spec. (Note that the factories only generate test users with a uid and email that match the auth payload used in the `AuthHelper` - these factories do not encapsulate any actual auth logic.)

To use the `AuthHelper` methods in a spec, simply call them in a `before` block:

```ruby
RSpec.describe 'Widgets', type: :request do
  describe 'GET /widgets' do
    subject(:get_widgets) { get widgets_path, headers: }

    # The 'authenticated' user won't actually be authenticated until you call #stub_successful_login,
    # so this is fine to define outside the relevant context.
    let!(:user) { create(:authenticated_user) }

    let(:headers) do
      {
        'Content-Type' => 'application/json',
        'Authorization' => 'Bearer xxxxxx' # this must be included in all specs for authenticated routes
      }
    end
    
    context 'when authenticated' do
      before do
        stub_successful_login
      end

      it 'returns status 200' do
        get_widgets
        expect(response.status).to eq(200)
      end
    end
    
    context 'when authentication fails' do
      before do
        stub_failed_login
      end

      it 'returns status 401' do
        get_widgets
        expect(response.status).to eq(401)
      end
    end
  end
end
```