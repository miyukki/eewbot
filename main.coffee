Twit = require 'twit'
request = require 'request'
EEWPayload = require './EEWPayload'
TweetPayload = require './TweetPayload'

TV_CAPTURE_URL = process.env.TV_CAPTURE_URL
WNI_CAPTURE_URL = process.env.WNI_CAPTURE_URL
UPLOADER_URL = process.env.UPLOADER_URL
SLACK_WEBHOOK_URL = process.env.SLACK_WEBHOOK_URL
TWITTER_NERV_ID = 116548789
TWITTER_TSUNAMITELOP_ID = 323709099
TWITTER_EEWBOT_ID = 214358709

twit = new Twit(
  consumer_key: process.env.TWITTER_CONSUMER_KEY
  consumer_secret: process.env.TWITTER_CONSUMER_SECRET
  access_token: process.env.TWITTER_ACCESS_TOKEN
  access_token_secret: process.env.TWITTER_ACCESS_TOKEN_SECRET
)

alermEarthquakeIds = []

twit.stream('statuses/filter', { follow: [TWITTER_EEWBOT_ID, TWITTER_NERV_ID, TWITTER_TSUNAMITELOP_ID].join(',') })
    .on('tweet', (tweet) ->
      return if tweet.retweeted_status? || tweet.in_reply_status_id?
      console.log("get tweet id=#{tweet.id} screen_name=#{tweet.user.screen_name} text=#{tweet.text.replace(/[\r\n]/g, '')}")

      payload =
        if tweet.user.id == TWITTER_TSUNAMITELOP_ID
          new TweetPayload(tweet)
        else if tweet.user.id == TWITTER_NERV_ID && tweet.text.indexOf('地震情報') != -1
          new TweetPayload(tweet)
        else if tweet.user.id == TWITTER_EEWBOT_ID
          new EEWPayload(tweet.text)

      if payload? && payload.shouldNotify()
        console.log("payload will be notify id=#{tweet.id}")
        payload.notifySlackMessage(postSlackWebhook)

        if payload instanceof EEWPayload && payload.isAlarm() && !alermEarthquakeIds.includes(payload.earthquakeId)
          alermEarthquakeIds.push(payload.earthquakeId)
          formData = payload.buildSlackMessage()
          formData.text = '緊急地震速報が発令されました'
          formData.channel = '#random'
          postSlackWebhook(formData)
        if payload instanceof EEWPayload && payload.isLastMessage()
          captureTelevision(postSlackWebhook)
          captureWni(postSlackWebhook)
    )

captureTelevision = (postFunction) ->
  console.log("capture television")
  return unless TV_CAPTURE_URL? && UPLOADER_URL?
  request.get(url: TV_CAPTURE_URL, encoding: null, (err, response, body) ->
    formData =
      file:
        value:  body
        options:
          filename: 'capture.jpg'
          contentType: 'image/jpeg'
    request.post(url: UPLOADER_URL, formData: formData, (err, response, body) ->
      formData =
        username: 'TV'
        icon_emoji: ':tv:'
        attachments: [
          title: "NHK総合テレビジョン"
          image_url: body
        ]
      postFunction(formData)
    )
  )

captureWni = (postFunction) ->
  console.log("capture wni")
  return unless WNI_CAPTURE_URL? && UPLOADER_URL?
  request.get(url: WNI_CAPTURE_URL, encoding: null, (err, response, body) ->
    formData =
      file:
        value:  body
        options:
          filename: 'capture.jpg'
          contentType: 'image/jpeg'
    request.post(url: UPLOADER_URL, formData: formData, (err, response, body) ->
      formData =
        username: 'TV'
        icon_emoji: ':tv:'
        attachments: [
          title: "ウェザーニュース"
          image_url: body
        ]
      postFunction(formData)
    )
  )

postSlackWebhook = (formData) ->
  console.log("post slack webhook", formData)
  request.post(url: SLACK_WEBHOOK_URL, form: JSON.stringify(formData), json: true, (error, response, body) ->
    if error
      console.error(error)
  )
