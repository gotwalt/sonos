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
speaker = Sonos.discover
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
speaker.queue
speaker.save_queue 'Jams'
speaker.clear_queue
```

### Topology

`Sonos.discover` finds the first speaker it can. We can get all of the Sonos devices (including Bridges, etc) by calling `speaker.topology`. This is going to get refactored a bit. Right now everything is nested under speaker which is kinda messy and confusing.

### CLI

There is a very limited CLI right now. You can run `sonos discover` to get the IP of one of your devices. Run `sonos discover --all` to get all of them.

## To Do

* Refactor all of the things
* Nonblocking calls with Celluloid::IO
* List other speakers
* Alarm clock
* Group management
    * Party Mode
    * Join
* Line-in (I don't have a PLAY:5, so I'll need help testing this one)
* Handle errors better
* Fix album art in `now_playing`
* Handle line-in in `now_playing`
* Better support for stero pairs
* CLI client for everything

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
