Twit = require 'twit'
request = require 'request'
EEWPayload = require './EEWPayload'
TweetPayload = require './TweetPayload'

SLACK_WEBHOOK_URL = process.env.SLACK_WEBHOOK_URL

twit = new Twit(
  consumer_key: process.env.TWITTER_CONSUMER_KEY
  consumer_secret: process.env.TWITTER_CONSUMER_SECRET
  access_token: process.env.TWITTER_ACCESS_TOKEN
  access_token_secret: process.env.TWITTER_ACCESS_TOKEN_SECRET
)

TWITTER_EEWBOT_ID = 214358709
TWITTER_TSUNAMITELOP_ID = 323709099

twit.stream('statuses/filter', { follow: [TWITTER_EEWBOT_ID, TWITTER_TSUNAMITELOP_ID].join(',') })
    .on('tweet', (tweet) ->
      return if tweet.retweeted_status?
      console.log(tweet)

      payload =
        if tweet.user.id == TWITTER_TSUNAMITELOP_ID
          new TweetPayload(tweet)
        else if tweet.user.id == TWITTER_EEWBOT_ID
          new EEWPayload(tweet.text)

      if payload? && payload.shouldNotify()
        postSlackWebhook(payload.buildSlackMessage())
    )

postSlackWebhook = (formData) ->
  request.post(url: SLACK_WEBHOOK_URL, form: JSON.stringify(formData), json: true, (error, response, body) ->
    console.log error, "Posted: ", formData
  )
