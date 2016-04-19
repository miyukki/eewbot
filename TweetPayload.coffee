class TweetPayload
  constructor: (@tweet) ->

  shouldNotify: ->
    true

  buildSlackMessage: ->
    tweetUrl = "https://twitter.com/#{@tweet.screen_name}/status/#{@tweet.id}"
    icon_url: @tweet.user.profile_image_url_https
    username: @tweet.user.name
    text: "#{@tweet.text} <#{tweetUrl}|Status>"

module.exports = TweetPayload
