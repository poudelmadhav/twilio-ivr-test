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

before do
  puts "=" * 50
  puts "Request Params: #{params.inspect}"
  puts "=" * 50
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
    response.gather(num_digits: 1, action: '/handle-key', input: 'speech dtmf', timeout: 10, speech_timeout: 5, enhanced: true, speech_model: 'googlev2_telephony', language: 'en-US') do |gather|
      gather.say(message: 'Press or say 1 for a friendly greeting. Press or say 2 for a special message.')
    end

    response.say(message: 'We did not receive any input. Please try again.')
    response.redirect('/')
  end.to_s
end

get_or_post '/handle-key' do
  content_type 'text/xml'

  Twilio::TwiML::VoiceResponse.new do |response|
    input = (params['Digits'] || params['SpeechResult']&.strip)&.downcase
    case input
    when '1', 'one'
      call_webhook(PRESS_1_WEBHOOK_URL, '1')
      response.say(message: 'You pressed 1. Thank you. Goodbye.')
    when '2', 'two'
      call_webhook(PRESS_2_WEBHOOK_URL, '2')
      response.say(message: 'You pressed 2. You are a real hero. See you soon. Goodbye.')
    else
      response.say(message: 'Invalid input. Please press 1 or 2.')
      response.redirect('/')
    end
  end.to_s
end
