class EEWPayload
  MessageType:
    Type1: 0x01
    Type2: 0x02
    Cancel: 0x03

  TrainingFlag:
    Normal: 0x01
    Test: 0x02

  WarningState:
    Normal: 0x01
    WrongCancel: 0x02
    Last: 0x03

  constructor: (message) ->
    [ @messageType, @testFlag, @messageTime, @state, @messageId, @earthquakeId,
      @earthquakeTime, @latitude, @longitude, @hypocenterName, @depth,
      @magnitude, @maxIntensity, @hypocenterOcean, @alarm] = message.split(',')

  isTest: ->
    @testFlag == '01'

  isAlarm: ->
    @alarm == '1'

  isOcean: ->
    @hypocenterOcean == '1'

module.exports = EEWPayload
