TweetPayload = require './TweetPayload'

class EEWPayload extends TweetPayload
  constructor: (message) ->
    [ @messageType, @testFlag, @messageTime, @state, @messageId, @earthquakeId,
      @earthquakeTime, @latitude, @longitude, @hypocenterName, @depth,
      @magnitude, @maxIntensity, @hypocenterOcean, @alarm] = message.split(',')

  isEstimatedMagnitude: ->
    @messageType == '36' || @messageType == '37'

  isCancel: ->
    @messageType == '39'

  isTest: ->
    @testFlag == '01'

  isAlarm: ->
    @alarm == '1'

  isOcean: ->
    @hypocenterOcean == '1'

  isLastMessage: ->
    @state == '8' || @state == '9'

  shouldNotify: ->
    @earthquakeId? && !@isCancel()

  notifySlackMessage: (postFunction) ->
    formData = @buildSlackMessage()
    postFunction(formData)

    if @isLastMessage() && @isAlarm()
      formData.text = '緊急地震速報が発令されました'
      formData.channel = '#random'
      postFunction(formData)

  buildSlackMessage: ->
    color =
      if @isTest()
        'good'
      else if @isAlarm()
        'danger'
      else
        'warning'

    imageUrl = "https://maps.googleapis.com/maps/api/staticmap?center=#{@latitude},#{@longitude}" +
               "&zoom=6&size=640x400&markers=color:red%7C#{@latitude},#{@longitude}"
    landSeaText = if @isOcean() then '海' else '陸'
    stageText = if @isLastMessage() then '最終報' else "第#{@messageId}報"

    attachment =
      author_name: "#{@earthquakeId}:#{@messageId}:#{stageText}"
      pretext: "最大震度 #{@maxIntensity} の地震が #{@hypocenterName}[#{landSeaText}] で発生しました"
      color: color
      image_url: if @messageId == '1' then imageUrl else null
      fields: [
          title: "最大震度"
          value: @maxIntensity
          short: true
        ,
          title: "マグニチュード"
          value: if @isEstimatedMagnitude() then @magnitude else '情報なし'
          short: true
        ,
          title: "震源地"
          value: @hypocenterName
          short: true
        ,
          title: "地震発生時刻"
          value: @earthquakeTime
          short: true
      ]

    username: '緊急地震速報[EEW]'
    attachments: [
      attachment
    ]

module.exports = EEWPayload
