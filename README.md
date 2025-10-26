# Igata(鋳型)

Generate test code from AST node produces by Ruby's Parser

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add igata
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install igata
```

## Usage

### Basic Usage

Generate Minitest tests (default):

```bash
bundle exec igata lib/user.rb > test/test_user.rb
```

Generate RSpec tests:

```bash
bundle exec igata lib/user.rb -f rspec > spec/user_spec.rb
# or
bundle exec igata lib/user.rb --formatter rspec > spec/user_spec.rb
```

### Supported Formatters

- `minitest` (default): Generates Minitest-style tests
- `rspec`: Generates RSpec-style tests

### Example

Given a Ruby class:

```ruby
class User
  def initialize(name, age)
    @name = name
    @age = age
  end

  def adult?
    @age >= 18
  end
end
```

Minitest output:

```ruby
# frozen_string_literal: true

require "test_helper"

class UserTest < Minitest::Test
  def test_initialize
    skip "Not implemented yet"
  end

  def test_adult?
    # Comparisons: >= (@age >= 18)
    skip "Not implemented yet"
  end
end
```

RSpec output:

```ruby
# frozen_string_literal: true

require "spec_helper"

RSpec.describe User do
  describe "#initialize" do
    it "works correctly" do
      pending "Not implemented yet"
    end
  end

  describe "#adult?" do
    # Comparisons: >= (@age >= 18)
    it "works correctly" do
      pending "Not implemented yet"
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/S-H-GAMELINKS/igata.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
