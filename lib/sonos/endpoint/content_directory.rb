module Sonos::Endpoint::ContentDirectory
  CONTENT_DIRECTORY_ENDPOINT = '/MediaServer/ContentDirectory/Control'
  CONTENT_DIRECTORY_XMLNS = 'urn:schemas-upnp-org:service:ContentDirectory:1'

  # Get the current queue
  def queue(starting_index = 0, requested_count = 100)
    name = 'Browse'
    action = "#{CONTENT_DIRECTORY_XMLNS}##{name}"
    message = %Q{<u:#{name} xmlns:u="#{CONTENT_DIRECTORY_XMLNS}"><ObjectID>Q:0</ObjectID><BrowseFlag>BrowseDirectChildren</BrowseFlag><Filter>dc:title,res,dc:creator,upnp:artist,upnp:album,upnp:albumArtURI</Filter><StartingIndex>#{starting_index}</StartingIndex><RequestedCount>#{requested_count}</RequestedCount><SortCriteria></SortCriteria></u:Browse>}
    result = content_directory_client.call name, soap_action: action, message: message
    body = result.body[:browse_response]

    hash = {
      total: body[:total_matches].to_i,
      items: parse_items(body[:result])
    }

    # Paginate
    # TODO: This is ugly and inflexible
    if starting_index == 0
      start = starting_index
      while hash[:items].count < hash[:total]
        start += requested_count
        hash[:items] += browse(start, requested_count)[:items]
      end
    end

    hash
  end

private

  def content_directory_client
    @content_directory_client ||= Savon.client endpoint: "http://#{self.ip}:#{Sonos::PORT}#{CONTENT_DIRECTORY_ENDPOINT}", namespace: Sonos::NAMESPACE
  end

  def parse_items(string)
    result = []
    doc = Nokogiri::XML(string)
    doc.css('item').each do |item|
      res = item.css('res').first
      result << {
        title: item.xpath('dc:title').inner_text,
        artist: item.xpath('dc:creator').inner_text,
        album: item.xpath('upnp:album').inner_text,
        album_art: "http://#{self.ip}:#{PORT}#{item.xpath('upnp:albumArtURI').inner_text}",
        duration: res['duration'],
        id: res.inner_text
      }
    end
    result
  end
end
