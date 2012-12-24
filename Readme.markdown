# Sonos

Control Sonos speakers with Ruby.

Huge thanks to [Rahim Sonawalla](https://github.com/rahims) for making [SoCo](https://github.com/rahims/SoCo). This gem would not be possible without his work.

## Installation

Add this line to your application's Gemfile:

``` ruby
gem 'sonos'
```

And then execute:

``` shell
$ bundle
```

Or install it yourself as:

``` shell
$ gem install sonos
```

## Usage

I'm working on a CLI client. For now, we'll use IRB.

``` shell
$ gem install sonos
$ irb
```

``` ruby
require 'rubygems'
require 'sonos'
ip = Sonos.discover
speaker = Sonos::Speaker(ip)
```

Now that we have a reference to the speaker, we can do all kinds of stuff.

``` ruby
speaker.pause # Pause whatever is playing
speaker.play  # Resumes the playlist
speaker.play 'http://assets.samsoff.es/music/Airports.mp3' # Stream!
speaker.now_playing
speaker.volume
speaker.volume = 70
speaker.volume -= 10
```

Finding multiple devices can be done synchronously:

``` ruby
require 'rubygems'
require 'sonos'
Sonos.discover_multiple.map do |ip|
  Sonos::Speaker.new(ip)
end
```

## To Do

* List other speakers
* Loudness
* Alarm clock
* Group management
    * Party Mode
    * Join
* Learn what all of the endpoints in `speaker.device_description_url` do
* Line-in (I don't have a PLAY:5, so I'll need help testing this one)
* Handle errors better
* Fix album art in `now_playing`
* Handle line-in in `now_playing`
* Better support for stero pairs
* CLI client

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
