class TweetPayload
  constructor: (@tweet) ->

  shouldNotify: ->
    true

  buildSlackMessage: ->
    tweetUrl = "https://twitter.com/#{@tweet.screen_name}/status/#{@tweet.id}"

    attachments = []
    for media in @tweet.entities.media
      continue if media.type != 'photo'
      attachments.push(
        image_url: media.media_url_https
      )

    icon_url: @tweet.user.profile_image_url_https
    username: @tweet.user.name
    text: "#{@tweet.text} <#{tweetUrl}|Status>"
    attachments: attachments

module.exports = TweetPayload
