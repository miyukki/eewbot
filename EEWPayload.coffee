class EEWPayload
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

module.exports = EEWPayload
