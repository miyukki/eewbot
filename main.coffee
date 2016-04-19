Twit = require 'twit'
request = require 'request'
EEWPayload = require './EEWPayload'

SLACK_WEBHOOK_URL = process.env.SLACK_WEBHOOK_URL

twit = new Twit(
  consumer_key: process.env.TWITTER_CONSUMER_KEY
  consumer_secret: process.env.TWITTER_CONSUMER_SECRET
  access_token: process.env.TWITTER_ACCESS_TOKEN
  access_token_secret: process.env.TWITTER_ACCESS_TOKEN_SECRET
)

twit.stream('statuses/filter', { follow: '214358709' })
    .on('tweet', (tweet) ->
      console.log(tweet)
      payload = new EEWPayload(tweet.text)
      postPayloadToSlack(payload)
    )

postPayloadToSlack = (payload) ->
  color =
    if payload.isTest()
      'good'
    else if payload.isAlarm()
      'danger'
    else
      'warning'

  imageUrl = "https://maps.googleapis.com/maps/api/staticmap?center=#{payload.latitude},#{payload.longitude}" +
             "&zoom=6&size=640x400&markers=color:red%7C#{payload.latitude},#{payload.longitude}"

  attachment =
    # author_name: "＜テスト＞"
    text: "震源地:#{payload.hypocenterName} 最大震度:#{payload.maxIntensity}"
    color: color
    image_url: imageUrl
    fields: [
        title: "最大震度"
        value: payload.maxIntensity
        short: true
      ,
        title: "マグニチュード"
        value: payload.magnitude
        short: true
      ,
        title: "震源地"
        value: payload.hypocenterName
        short: true
      ,
        title: "地震発生時刻"
        value: payload.earthquakeTime
        short: true
    ]

  payload =
    attachments: [
      attachment
    ]

  request.post(url: SLACK_WEBHOOK_URL, form: JSON.stringify(payload), json: true, (error, response, body) ->
    console.log error, response, body
  )

# payload = new EEWPayload('37,00,2011/04/03 23:53:51,0,2,ND20110403235339,2011/04/03 23:53:21,37.8,142.3,宮城県沖,10,4.5,2,1,0')
# postPayloadToSlack(payload)
