# Sonos

Control Sonos speakers with Ruby.

Huge thanks to [Rahim Sonawalla](https://github.com/rahims) for making [SoCo](https://github.com/rahims/SoCo). Control would not be possible without his work.

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

I'm working on a CLI client. For now, we'll use IRB. You will need the IP address of a speaker (auto-detection is on my list too). To get the IP of a speaker, one of your Sonos controllers and go to "About My Sonos System".

``` shell
$ gem install sonos
$ irb
```

``` ruby
require 'rubygems'
require 'sonos'
speaker = Sonos::Speaker('10.0.1.10') # or whatever the IP is
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

## To Do

* Mute
* Bass
* Treble
* Loudness
* Party Mode
* Join
* Line-in
* Status Light
* Handle errors better
* Fix album art in `now_playing`
* Handle line-in in `now_playing`
* Auto-discovery
* Better support for stero pairs
* CLI client

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
