# Assertable

Allows for assertions in your code.

```ruby
class Bottle
  include Assertable
 
  def initialize(volume_in_ml:)
    assert volumne_in_ml > 0
    @volume_in_ml = volume_in_ml
  end
end
Bottle.new volume_in_ml: 1500
=> #<Bottle:0x000056533e319100>

Bottle.new volume_in_ml: -100
=> Assertable::Assertion
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'assertable'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install assertable

## Usage

Including in your class:
```ruby
class Bottle
  include Assertable
 
  def initialize(volume_in_ml:)
    assert volumne_in_ml > 0
    @volume_in_ml = volume_in_ml
  end
end
Bottle.new volume_in_ml: 1500
=> #<Bottle:0x000056533e319100>

Bottle.new volume_in_ml: -100
=> raises Assertable::Assertion
```

We try to follow MiniTest style of assertions. Current list:
- assert_send
- assert
- assert_equal
- assert_includes
- assert_kind_of
- assert_nil
- refute
- refute_equal

## Development

Run `bundle exec rake test` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Facilecomm/assertable. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/assertable/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Assertable project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/Facilecomm/assertable/blob/master/CODE_OF_CONDUCT.md).
