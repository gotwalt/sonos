require 'test_helper'

class SystemTest < SonosTest
  def test_singleton
    assert_equal Sonos.system.object_id, Sonos.system.object_id
  end

  def test_group_detection
    VCR.use_cassette('topology', match_requests_on: [:path]) do
      system = Sonos.system
      assert_equal 1, system.groups.length
    end
  end
end
