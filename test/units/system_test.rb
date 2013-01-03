require 'test_helper'

class SystemTest < SonosTest
  def test_group_detection
    VCR.use_cassette('topology') do
      system = Sonos.system
      assert_equal 1, system.groups.length
    end
  end
end
