require 'dotenv/load'
require 'sinatra'
require 'twilio-ruby'
require 'net/http'
require 'uri'

PRESS_1_WEBHOOK_URL = ENV.fetch('PRESS_1_WEBHOOK_URL')
PRESS_2_WEBHOOK_URL = ENV.fetch('PRESS_2_WEBHOOK_URL')

configure :development do
  set :host_authorization, { permitted_hosts: [] }
end

def self.get_or_post(url, &block)
  get(url, &block)
  post(url, &block)
end

def call_webhook(url, digit)
  uri = URI(url)
  Net::HTTP.post_form(uri, 'digit' => digit)
rescue StandardError => e
  warn "Webhook failed for digit #{digit}: #{e.message}"
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
      call_webhook(PRESS_1_WEBHOOK_URL, '1')
      response.say(message: 'You pressed 1. Thank you. Goodbye.')
    when '2'
      call_webhook(PRESS_2_WEBHOOK_URL, '2')
      response.say(message: 'You pressed 2. You are a real hero. See you soon. Goodbye.')
    else
      response.say(message: 'Invalid input. Please press 1 or 2.')
      response.redirect('/')
    end
  end.to_s
end
