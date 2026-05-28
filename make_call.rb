# Download the helper library from https://www.twilio.com/docs/ruby/install
require 'dotenv/load'
require 'twilio-ruby'

# Find your Account SID and Auth Token at twilio.com/console
# and set the environment variables. See http://twil.io/secure
account_sid = ENV['TWILIO_ACCOUNT_SID']
auth_token = ENV['TWILIO_AUTH_TOKEN']
@client = Twilio::REST::Client.new(account_sid, auth_token)

call = @client
       .api
       .v2010
        .calls
        .create(
          url: ENV.fetch('TWILIO_VOICE_URL'),
          to: ENV.fetch('TWILIO_TO_NUMBER'),
          from: ENV.fetch('TWILIO_FROM_NUMBER')
        )

puts call.sid
