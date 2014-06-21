module Sonos::Features::Voiceover

  # Interrupts the speaker and plays the provided URI. When finished, returns the play head
  # and state to their original position. Useful for doorbell sounds, announcements, etc.
  def voiceover!(uri, vol = nil)
    start_time = Time.now

    result = group_master.with_isolated_state do
      self.volume = vol if vol
      group_master.play_blocking(uri)
    end

    result.merge({duration: (Time.now - start_time )})
  end

  protected

  def with_isolated_state
    pause if was_playing = is_playing?
    unmute if was_muted = muted?
    previous_volume = volume
    previous = now_playing

    yield

    # the sonos app does this. I think it tells the player to think of the master queue as active again
    play uid.gsub('uuid', 'x-rincon-queue') + '#0'

    if previous
      select_track previous[:queue_position]
      seek Time.parse("1/1/1970 #{previous[:current_position]} -0000" ).to_i

      self.volume = previous_volume
      mute if was_muted
    end

    play if was_playing

    {
      original_volume: previous_volume,
      original_state: (was_playing ? 'playing' : 'paused')
    }
  end

  def play_blocking(uri)
    puts "Playing track #{uri} on speaker #{name}"

    # queue up the track
    play uri

    # play it
    play

    # pause the thread until the track is done
    sleep(0.1) while is_playing?
  end

end
