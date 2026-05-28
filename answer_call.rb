require 'sinatra'
require 'twilio-ruby'

configure :development do
  set :host_authorization, { permitted_hosts: [] }
end

def self.get_or_post(url, &block)
  get(url, &block)
  post(url, &block)
end

get_or_post '/' do
  content_type 'text/xml'

  Twilio::TwiML::VoiceResponse.new do |response|
    response.gather(num_digits: 1, action: '/handle-key', method: 'POST') do |gather|
      gather.say(message: 'Please press 1 or 2.')
    end

    response.say(message: 'We did not receive any input. Goodbye.')
  end.to_s
end

get_or_post '/handle-key' do
  content_type 'text/xml'

  Twilio::TwiML::VoiceResponse.new do |response|
    case params['Digits']
    when '1'
      response.say(message: 'You pressed 1. Thank you. Goodbye.')
    when '2'
      response.say(message: 'You pressed 2. You are a real hero. See you soon. Goodbye.')
    else
      response.say(message: 'Invalid input. Please press 1 or 2.')
      response.redirect('/')
    end
  end.to_s
end
