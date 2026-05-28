# Twilio Voice Call Demo

This project uses Ruby, Sinatra, and Twilio to answer calls, ask the caller to press `1` or `2`, speak a response, and call a webhook based on the selected digit.

## Setup

Install dependencies:

```bash
bundle install
```

Create/update `.env`:

```env
TWILIO_ACCOUNT_SID=your_twilio_account_sid_here
TWILIO_AUTH_TOKEN=your_twilio_auth_token_here
TWILIO_FROM_NUMBER=+10000000000
TWILIO_TO_NUMBER=+10000000000
TWILIO_VOICE_URL=https://dynamic-tarpon-valued.ngrok-free.app/
PRESS_1_WEBHOOK_URL=https://webhook.site/d37bc9df-5c98-445d-a7c7-7ba762ee127f
PRESS_2_WEBHOOK_URL=https://webhook.site/08afa4ae-ceaf-4e1e-8b20-f7a986ad7e8d
```

Replace `TWILIO_ACCOUNT_SID` and `TWILIO_AUTH_TOKEN` with your Twilio credentials.

## Run The Call Server

Start the Sinatra server:

```bash
bundle exec ruby answer_call.rb
```

By default, Sinatra runs locally on port `4567`.

Expose the local server with ngrok:

```bash
ngrok http 4567
```

Copy the HTTPS ngrok URL and update `TWILIO_VOICE_URL` in `.env`.

Example:

```env
TWILIO_VOICE_URL=https://dynamic-tarpon-valued.ngrok-free.app/
```

## Receive Calls

In the Twilio Console, open your Twilio phone number settings.

Set the voice webhook for incoming calls to your ngrok URL:

```text
https://dynamic-tarpon-valued.ngrok-free.app/
```

Use `HTTP POST` or `HTTP GET`.

When someone calls your Twilio number, the app will ask them to press `1` or `2`.

## Make Outbound Calls

Make sure the server is running and `TWILIO_VOICE_URL` points to your public ngrok URL.

Then run:

```bash
bundle exec ruby make_call.rb
```

Twilio will call `TWILIO_TO_NUMBER` from `TWILIO_FROM_NUMBER`. After the user answers, Twilio requests `TWILIO_VOICE_URL` and plays the same `1` or `2` prompt.

## Keypress Behavior

If the caller presses `1`:

```text
You pressed 1. Thank you. Goodbye.
```

The app also sends a POST request to `PRESS_1_WEBHOOK_URL` with:

```text
digit=1
```

If the caller presses `2`:

```text
You pressed 2. You are a real hero. See you soon. Goodbye.
```

The app also sends a POST request to `PRESS_2_WEBHOOK_URL` with:

```text
digit=2
```

## Useful Checks

Check Ruby syntax:

```bash
ruby -c answer_call.rb
ruby -c make_call.rb
```
