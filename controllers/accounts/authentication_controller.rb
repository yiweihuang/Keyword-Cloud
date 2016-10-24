# Sinatra Application Controllers
class KeywordCloudAPI < Sinatra::Base
  post '/api/v1/accounts/authenticate' do
    content_type 'application/json'

    credentials = JSON.parse(request.body.read)
    uid, auth_token = AuthenticateAccount.call(
      account: credentials['account'],
      password: credentials['password'])
    if uid
      {
        uid: uid,
        auth_token: auth_token }.to_json
    else
      halt 401, 'User ID could not be authenticated'
    end
  end
end
