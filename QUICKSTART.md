# Quick Start Guide

Get started with Igata in 5 minutes.

## What is Igata?

Igata (鋳型 = mold/template) generates test code templates from your Ruby classes. It analyzes your code structure and creates test skeletons with helpful comments about branches and comparisons, so you can focus on writing test logic instead of boilerplate.

## Installation

```bash
gem install igata
```

Or add to your Gemfile:

```bash
bundle add igata
```

## Your First Test Generation

### 1. Create a sample Ruby class

Create a file `user.rb`:

```ruby
class User
  def initialize(name, age)
    @name = name
    @age = age
  end

  def adult?
    @age >= 18
  end

  def greeting
    if @name
      "Hello, #{@name}!"
    else
      "Hello, Guest!"
    end
  end
end
```

### 2. Generate Minitest (default)

```bash
igata user.rb > test/test_user.rb
```

Output:

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

  def test_greeting
    # Branches: if (@name)
    skip "Not implemented yet"
  end
end
```

### 3. Generate RSpec

```bash
igata user.rb -f rspec > spec/user_spec.rb
```

Output:

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

  describe "#greeting" do
    # Branches: if (@name)
    it "works correctly" do
      pending "Not implemented yet"
    end
  end
end
```

## Common Usage Patterns

### Generate from stdin

```bash
cat lib/user.rb | igata
```

### Specify output file

```bash
igata lib/user.rb -o test/test_user.rb
```

### Multiple formatters

```bash
# Minitest (default)
igata lib/user.rb > test/test_user.rb

# RSpec
igata lib/user.rb -f rspec > spec/user_spec.rb
```

## Understanding the Output

Igata adds helpful comments to guide your test implementation:

- **`# Branches:`** - Shows conditional logic (if/unless/case) with conditions
- **`# Comparisons:`** - Shows comparison operators (>=, <=, >, <, ==, !=) suggesting boundary value tests

These comments help you:
1. Identify edge cases to test
2. Write comprehensive test coverage
3. Understand method complexity at a glance
4. **Assist LLMs** - GitHub Copilot, Claude, ChatGPT, and other LLMs may use these comments as context to generate more appropriate test code

## Next Steps

- See [README.md](README.md) for complete documentation
- Check [CHANGELOG.md](CHANGELOG.md) for feature details
- Write your test logic inside the generated skeleton
- Remove `skip` / `pending` statements as you implement tests

## Tips

1. **Nested classes work**: `class User::Profile` generates proper test structure
2. **Run tests first**: Generated tests use `skip`/`pending` so they won't fail
3. **Combine with TDD**: Generate template → Write test logic → Implement feature
4. **Use comments**: Branch and comparison comments guide your test cases

## Need Help?

- [GitHub Issues](https://github.com/S-H-GAMELINKS/igata/issues)
- [Full Documentation](README.md)
