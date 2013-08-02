# POST /AlarmClock/Control HTTP/1.1
# SOAPACTION: "urn:schemas-upnp-org:service:AlarmClock:1#ListAlarms"

# Request
#<?xml version="1.0" encoding="UTF-8"?>
#<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
#    <s:Body>
#      <u:ListAlarms xmlns:u="urn:schemas-upnp-org:service:AlarmClock:1" />
#    </s:Body>
#</s:Envelope>

# Response
#<?xml version="1.0" encoding="UTF-8"?>
#<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
#  <s:Body>
#    <u:ListAlarmsResponse xmlns:u="urn:schemas-upnp-org:service:AlarmClock:1">
#      <CurrentAlarmList>&lt;Alarms&gt;&lt;Alarm ID="8" StartTime="19:21:00" Duration="02:00:00" Recurrence="ONCE" Enabled="0" RoomUUID="RINCON_000E583564A601400" ProgramURI="x-rincon-buzzer:0" ProgramMetaData="" PlayMode="SHUFFLE_NOREPEAT" Volume="25" IncludeLinkedZones="0"/&gt;&lt;/Alarms&gt;</CurrentAlarmList>
#      <CurrentAlarmListVersion>RINCON_000E583564A601400:26</CurrentAlarmListVersion>
#    </u:ListAlarmsResponse>
#  </s:Body>
#</s:Envelope>

module Sonos::Endpoint::Alarm
  ALARM_CLOCK_ENDPOINT = '/AlarmClock/Control'
  ALARM_CLOCK_XMLNS = 'urn:schemas-upnp-org:service:AlarmClock:1'

  # List the alarms that have been defined
  def list_alarms
    hash_of_alarm_hashes = {}
    response = send_alarm_message('ListAlarms')
    alarm_list_reader = Nokogiri::XML::Reader(response.to_hash[:list_alarms_response][:current_alarm_list])
    alarm_list_reader.each do |alarm_node|
      alarm_hash = {
          :ID => alarm_node.attribute('ID'),
          :StartLocalTime => alarm_node.attribute('StartLocalTime'),
          :Duration => alarm_node.attribute('Duration'),
          :Recurrence => alarm_node.attribute('Recurrence'),
          :Enabled => alarm_node.attribute('Enabled'),
          :RoomUUID => alarm_node.attribute('RoomUUID'),
          :PlayMode => alarm_node.attribute('PlayMode'),
          :Volume => alarm_node.attribute('Volume'),
          :IncludeLinkedZones => alarm_node.attribute('IncludeLinkedZones'),
          :ProgramURI => alarm_node.attribute('ProgramURI'),
          :ProgramMetaData => alarm_node.attribute('ProgramMetaData')
      }
      hash_of_alarm_hashes[alarm_hash[:ID]] = alarm_hash
    end
    return hash_of_alarm_hashes
  end

  def create_alarm(startLocalTime, duration, recurrence, enabled, roomUuid, playMode, volume, includeLinkedZones, programUri, programMetaData)
    options = {:StartLocalTime => startLocalTime, :Duration => duration,
               :Recurrence => recurrence, :Enabled => enabled, :RoomUUID => roomUuid,
               :PlayMode => playMode, :Volume => volume, :IncludeLinkedZones => includeLinkedZones,
               :ProgramURI => programUri, :ProgramMetaData => programMetaData}
    #options = {:StartLocalTime => '13:19:00', :Duration => '02:00:00',
    #           :Recurrence => 'ONCE', :Enabled => 1, :RoomUUID => 'RINCON_000E583564A601400',
    #           :PlayMode => 'SHUFFLE_NOREPEAT', :Volume => 25, :IncludeLinkedZones => 0,
    #           :ProgramURI => 'x-rincon-buzzer:0', :ProgramMetaData => nil}
    send_alarm_message('CreateAlarm', convert_hash_to_xml(options))
  end

  def destroy_alarm(id)
    send_alarm_message('DestroyAlarm', "<ID>#{id}</ID>")
  end

  def update_alarm(id, startLocalTime, duration, recurrence, enabled, roomUuid, playMode, volume, includeLinkedZones, programUri, programMetaData)
    alarm_hash = {:ID => id, :StartLocalTime => startLocalTime, :Duration => duration,
               :Recurrence => recurrence, :Enabled => enabled, :RoomUUID => roomUuid,
               :PlayMode => playMode, :Volume => volume, :IncludeLinkedZones => includeLinkedZones,
               :ProgramURI => programUri, :ProgramMetaData => programMetaData}
    #options = {:ID => 8, :StartLocalTime => '13:19:00', :Duration => '02:00:00',
    #           :Recurrence => 'ONCE', :Enabled => 1, :RoomUUID => 'RINCON_000E583564A601400',
    #           :PlayMode => 'SHUFFLE_NOREPEAT', :Volume => 25, :IncludeLinkedZones => 0,
    #           :ProgramURI => 'x-rincon-buzzer:0', :ProgramMetaData => nil}
    send_alarm_message('UpdateAlarm', convert_hash_to_xml(alarm_hash))
  end

  def is_alarm_enabled?(id)
    list_alarms[id][:Enabled]
  end

  def enable_alarm(id)
    alarm_hash = list_alarms[id]
    alarm_hash[:Enabled] = '1'
    send_alarm_message('UpdateAlarm', convert_hash_to_xml(alarm_hash))
  end

  def disable_alarm(id)
    alarm_hash = list_alarms[id]
    alarm_hash[:Enabled] = '0'
    send_alarm_message('UpdateAlarm', convert_hash_to_xml(alarm_hash))
  end

  private

  def alarm_client
    @alarm_client ||= Savon.client endpoint: "http://#{self.ip}:#{Sonos::PORT}#{ALARM_CLOCK_ENDPOINT}", namespace: Sonos::NAMESPACE
  end

  def send_alarm_message(name, part = '')
    action = "#{ALARM_CLOCK_XMLNS}##{name}"
    message = %Q{<u:#{name} xmlns:u="#{ALARM_CLOCK_XMLNS}">#{part}</u:#{name}>}
    alarm_client.call(name, soap_action: action, message: message)
  end

  def convert_hash_to_xml(options = {})
    updatePart = ''
    options.each do |optionKey, optionValue|
      updatePart += "<#{optionKey}>#{optionValue}</#{optionKey}>"
    end
    updatePart
  end

end