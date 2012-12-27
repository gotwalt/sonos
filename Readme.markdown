# Sonos

Control Sonos speakers with Ruby.

Huge thanks to [Rahim Sonawalla](https://github.com/rahims) for making [SoCo](https://github.com/rahims/SoCo). This gem would not be possible without his work.

[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/soffes/sonos)

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
speaker = Sonos.system.speakers.first
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

`Sonos.discover` finds the first speaker it can. We can get all of the Sonos devices (including Bridges, etc) by calling `Sonos.system.devices`. To get the groups, call `Sonos.system.groups`.

All of this is based off of the raw `Sonos.system.topology`.

### CLI

There is a very limited CLI right now. You can run `sonos discover` to get the IP of one of your devices. Run `sonos discover --all` to get all of them.

## To Do

### General

* Refactor all of the things
* Nonblocking calls with Celluloid::IO
* List other speakers
* Handle errors better
* Handle line-in in `now_playing`
* Detect fixed volume
* Detect stereo pair
* CLI client for everything

### Features

* Alarm clock
* Pause all (there is no play all in the controller, we could loop through and do it though)
* Group management
    * Party Mode
    * Join
* Line-in
* Toggle cross fade
* Toggle shuffle
* Set repeat mode
* Scrub
* Search music library
* Browse music library
* Add songs to queue
* Skip to song in queue
* Sleep timer

### Maybe

If we are implementing everything the official Sonos Controller does, here's some more stuff:

* Set zone name and icon
* Create stero pair
* Support for BRIDGE
* Support for DOCK
* Manage services
* Date and time
* Wireless channel
* Audio compression
* Automatically check for updates (not sure if this is a controller only preference)
* Local music servers

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
