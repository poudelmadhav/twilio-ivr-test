require 'sinatra'
require 'twilio-ruby'

configure :development do
  set :host_authorization, { permitted_hosts: [] }
end

def self.get_or_post(url,&block)
  get(url,&block)
  post(url,&block)
end

get_or_post '/' do
  content_type 'text/xml'

  Twilio::TwiML::VoiceResponse.new do | response |
    response.say(message: "Ahoy world!")
  end.to_s
end
