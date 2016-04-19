class TweetPayload
  constructor: (@tweet) ->

  shouldNotify: ->
    true

  buildSlackMessage: ->
    icon_url: @tweet.user.profile_image_url_https
    username: @tweet.user.name
    text: @tweet.text

module.exports = TweetPayload
