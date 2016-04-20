class TweetPayload
  constructor: (@tweet) ->

  shouldNotify: ->
    true

  buildSlackMessage: ->
    tweetText = @tweet.text
    attachments = []

    if @tweet.entities?.media?
      for media in @tweet.entities.media
        continue if media.type != 'photo'
        tweetText = tweetText.replace(media.url, '')
        attachments.push(
          image_url: media.media_url_https
        )

    icon_url: @tweet.user.profile_image_url_https
    username: @tweet.user.name
    text: tweetText
    attachments: attachments

module.exports = TweetPayload
