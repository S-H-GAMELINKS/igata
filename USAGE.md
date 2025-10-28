# Real-World Usage Scenarios

This document describes practical scenarios where Igata helps with test development in real projects.

## Table of Contents

- [Scenario 1: TDD for New Features](#scenario-1-tdd-for-new-features)
- [Scenario 2: Adding Tests to Legacy Code](#scenario-2-adding-tests-to-legacy-code)
- [Scenario 3: Rails Application Testing](#scenario-3-rails-application-testing)
- [Scenario 4: Refactoring with Safety Net](#scenario-4-refactoring-with-safety-net)
- [Scenario 5: Code Review - Test Coverage Check](#scenario-5-code-review---test-coverage-check)
- [Scenario 6: Team Development - Standardizing Test Skeletons](#scenario-6-team-development---standardizing-test-skeletons)
- [Scenario 7: LLM-Assisted Test Implementation](#scenario-7-llm-assisted-test-implementation)

---

## Scenario 1: TDD for New Features

**Context**: You're implementing a new feature using Test-Driven Development.

**Workflow**:

1. Design your class interface
2. Generate test skeleton with Igata
3. Write test logic based on generated hints
4. Implement the feature to pass tests

**Example**:

```bash
# 1. Create class interface
cat > lib/payment_validator.rb << 'EOF'
class PaymentValidator
  def initialize(amount, currency)
    @amount = amount
    @currency = currency
  end

  def valid?
    return false if @amount <= 0
    return false unless supported_currency?
    true
  end

  def supported_currency?
    @currency == "USD" || @currency == "EUR" || @currency == "JPY"
  end
end
EOF

# 2. Generate test skeleton
igata lib/payment_validator.rb > test/payment_validator_test.rb

# 3. Review generated hints
cat test/payment_validator_test.rb
```

Output shows:

```ruby
def test_valid?
  # Branches: if (@amount <= 0), unless (supported_currency?)
  # Comparisons: <= (@amount <= 0)
  skip "Not implemented yet"
end

def test_supported_currency?
  # Comparisons: == (@currency == "USD"), == (@currency == "EUR"), == (@currency == "JPY")
  skip "Not implemented yet"
end
```

**Benefits**:
- Branch hints suggest testing both positive and negative amounts
- Comparison hints suggest boundary value testing (0, negative, positive)
- Currency comparison hints suggest testing each supported currency plus unsupported ones

---

## Scenario 2: Adding Tests to Legacy Code

**Context**: You need to add tests to existing code without tests.

**Workflow**:

```bash
# Generate test skeleton for existing file
igata lib/legacy/order_processor.rb > test/legacy/order_processor_test.rb

# Review complexity from generated comments
# High number of branches/comparisons → complex method needing refactoring
```

**Example**:

```ruby
# Generated test reveals complexity
def test_process_order
  # Branches: if (order.paid?), if (order.shippable?), case (order.status), if (inventory.available?(order.items)), unless (order.address.valid?)
  # Comparisons: > (order.total > 1000), >= (customer.age >= 18), == (order.priority == "high")
  skip "Not implemented yet"
end
```

**Benefits**:
- Quickly see method complexity from comment density
- Branch/comparison hints guide edge case testing
- Identify refactoring opportunities before writing tests

---

## Scenario 3: Rails Application Testing

**Context**: Testing ActiveRecord models and service objects.

### ActiveRecord Models

```bash
# Generate test for User model
igata app/models/user.rb > test/models/user_test.rb
```

**Example Model**:

```ruby
class User < ApplicationRecord
  def adult?
    age >= 18
  end

  def display_name
    if name.present?
      name
    else
      "Guest #{id}"
    end
  end

  def subscription_active?
    return false unless subscription_ends_at
    subscription_ends_at > Time.current
  end
end
```

**Generated Test**:

```ruby
def test_adult?
  # Comparisons: >= (age >= 18)
  skip "Not implemented yet"
end

def test_display_name
  # Branches: if (name.present?)
  skip "Not implemented yet"
end

def test_subscription_active?
  # Branches: unless (subscription_ends_at)
  # Comparisons: > (subscription_ends_at > Time.current)
  skip "Not implemented yet"
end
```

**Benefits**:
- Hints suggest testing boundary ages (17, 18, 19)
- Branch hints suggest testing with/without name
- Comparison hints suggest testing time boundaries (expired, current, future)

### Service Objects

```bash
# Generate test for service object
igata app/services/subscription_renewal_service.rb -f rspec > spec/services/subscription_renewal_service_spec.rb
```

---

## Scenario 4: Refactoring with Safety Net

**Context**: You need to refactor complex methods but want test coverage first.

**Workflow**:

```bash
# 1. Generate test for current implementation
igata lib/report_generator.rb > test/report_generator_test.rb

# 2. Implement tests based on current behavior
# 3. Run tests → all pass
# 4. Refactor code
# 5. Run tests → ensure behavior unchanged
```

**Benefits**:
- Establish baseline behavior before refactoring
- Branch/comparison hints ensure edge cases are covered
- Confidence in refactoring safety

---

## Scenario 5: Code Review - Test Coverage Check

**Context**: Reviewing a pull request to ensure adequate test coverage.

**Workflow**:

```bash
# Generate test skeleton for changed files
igata lib/new_feature.rb > /tmp/expected_tests.rb

# Compare with actual tests in PR
diff /tmp/expected_tests.rb test/new_feature_test.rb
```

**Review Checklist**:
- Are all methods from generated skeleton tested?
- Are branch cases from comments covered?
- Are boundary values from comparison comments tested?

**Benefits**:
- Objective test coverage assessment
- Identify missing test cases quickly
- Standardized review criteria

---

## Scenario 6: Team Development - Standardizing Test Skeletons

**Context**: Team wants consistent test structure across projects.

**Setup**:

```bash
# Add to team's coding guidelines
echo "Generate test skeletons with: igata <file> > test/<file>_test.rb" >> CONTRIBUTING.md

# CI check for test existence
# .github/workflows/ci.yml
```

```yaml
- name: Check test coverage
  run: |
    for file in lib/**/*.rb; do
      test_file="test/$(basename $file .rb)_test.rb"
      if [ ! -f "$test_file" ]; then
        echo "Missing test: $test_file"
        exit 1
      fi
    done
```

**Benefits**:
- Consistent test structure across team
- New members quickly learn testing patterns
- Automated enforcement of test existence

---

## Scenario 7: LLM-Assisted Test Implementation

**Context**: Using GitHub Copilot, Claude, or ChatGPT to accelerate test writing.

**Workflow**:

```bash
# 1. Generate test skeleton with detailed hints
igata lib/calculator.rb > test/calculator_test.rb
```

**Generated**:

```ruby
def test_divide
  # Branches: if (divisor == 0)
  # Comparisons: == (divisor == 0)
  skip "Not implemented yet"
end
```

**2. LLM reads comments and suggests**:

```ruby
def test_divide
  # Branches: if (divisor == 0)
  # Comparisons: == (divisor == 0)

  # Test normal division
  calc = Calculator.new
  assert_equal 2, calc.divide(4, 2)

  # Test division by zero (branch hint)
  assert_raises(ZeroDivisionError) { calc.divide(4, 0) }

  # Test boundary cases (comparison hint)
  assert_equal 0, calc.divide(0, 2)
  assert_equal Float::INFINITY, calc.divide(1.0, 0)
end
```

**Benefits**:
- Comments provide context for LLM suggestions
- More accurate test generation from LLM
- Branch/comparison hints guide comprehensive coverage
- Faster test implementation with AI assistance

**LLM Tools Compatible**:
- GitHub Copilot
- Claude Code
- ChatGPT
- Amazon CodeWhisperer
- Cody (Sourcegraph)

---

## Integration with Development Tools

### Pre-commit Hook

```bash
# .git/hooks/pre-commit
#!/bin/bash
for file in $(git diff --cached --name-only --diff-filter=AM | grep '^lib/.*\.rb$'); do
  test_file="test/$(basename $file .rb)_test.rb"
  if [ ! -f "$test_file" ]; then
    echo "Generating test skeleton: $test_file"
    igata "$file" > "$test_file"
    git add "$test_file"
  fi
done
```

### Rake Task

```ruby
# lib/tasks/igata.rake
namespace :igata do
  desc "Generate missing test files"
  task :generate_missing do
    Dir.glob("lib/**/*.rb").each do |file|
      test_file = file.sub("lib/", "test/").sub(".rb", "_test.rb")
      unless File.exist?(test_file)
        puts "Generating: #{test_file}"
        system("igata #{file} > #{test_file}")
      end
    end
  end
end
```

### Editor Integration (VS Code)

```json
// .vscode/tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Generate Test with Igata",
      "type": "shell",
      "command": "igata ${file} > test/$(basename ${file} .rb)_test.rb",
      "presentation": {
        "reveal": "always"
      }
    }
  ]
}
```

---

## Best Practices

### 1. Use Branch/Comparison Hints as Test Case Guide

**Generated hint**:
```ruby
# Branches: if (@age >= 18), unless (@verified)
# Comparisons: >= (@age >= 18)
```

**Write tests for**:
- `@age >= 18` boundary: age = 17, 18, 19
- `@verified` states: true, false
- Combinations: (age < 18, verified), (age >= 18, not verified), etc.

### 2. Remove `skip`/`pending` After Implementation

```ruby
# Before
def test_adult?
  # Comparisons: >= (@age >= 18)
  skip "Not implemented yet"
end

# After
def test_adult?
  # Comparisons: >= (@age >= 18)
  user = User.new(name: "Alice", age: 17)
  refute user.adult?

  user = User.new(name: "Bob", age: 18)
  assert user.adult?
end
```

### 3. Keep Comments for Future Reference

Comments help:
- New team members understand test intent
- Future refactoring efforts
- LLM tools provide better suggestions

### 4. Regenerate After Major Refactoring

```bash
# Compare old and new structure
igata lib/refactored_class.rb > /tmp/new_tests.rb
diff test/refactored_class_test.rb /tmp/new_tests.rb
```

---

## Summary

Igata accelerates test development by:
- **Generating boilerplate** - Focus on test logic, not structure
- **Providing hints** - Branch/comparison comments guide edge case testing
- **Standardizing structure** - Consistent tests across team/projects
- **Enabling LLM assistance** - Comments provide context for better AI suggestions
- **Revealing complexity** - Comment density indicates refactoring needs

Choose the scenarios that fit your workflow and adapt them to your team's practices.
