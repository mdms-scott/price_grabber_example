# PriceGrabber

## TODO

## Installation

Add this line to your application's Gemfile to install the gem from github:

    gem 'price_grabber', :git => "git@github.com:HSSC/price_grabber.git"

Or clone the repository and run from source for development:

    gem 'price_grabber', :path => "/path/to/price_grabber"

And then execute:

    $ bundle install
    or
    $ bundle update price_grabber (if you are building from github)

## Requirements

PriceGrabber requires an application.yml to be found in the project's /config directory.  Expected format is a match to SparklingLips's application.yml.example.

In development PriceGrabber relies upon the 'rspec' gem, and in runtime it requires the 'rest-client' and 'json' gems.

## Testing

In order do run the specs you will need to create a config folder in the price_grabber directory with an application.yml inside. Example contents as follows:

    development: &development
      obis.entity.host: "localhost"
      obis.entity.port: 4567
    test:
      <<: *development

## Usage

PriceGrabber provides a series of utilities that can be called upon from the PriceGrabber module. For example:

    PriceGrabber.get_service_rate()
    PriceGrabber.get_ssr_rates()
    PriceGrabber.get_service_request_rates()

PriceGrabber includes the Common module found in the Migration Scripts project, prefixed as PriceGrabber::Common, and thus any project including the gem will have access to the common module methods.



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
