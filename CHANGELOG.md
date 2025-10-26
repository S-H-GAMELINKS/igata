## [Unreleased]

### Added

- Introduced Formatter architecture for supporting multiple test frameworks:
  - `Formatters::Base`: Abstract base class for all formatters
  - `Formatters::Minitest`: Minitest-specific formatter implementation
  - `MethodNotOverriddenError`: Custom error for abstract method violations
  - Separated `Igata::Error` into dedicated file
- Added CLI formatter option:
  - `-f, --formatter FORMATTER`: Specify test framework formatter (currently: minitest)
- Added comprehensive unit tests:
  - Extractor tests: `ConstantPath` (10 tests), `MethodNames` (6 tests)
  - Formatter tests: `Base` (3 tests), `Minitest` (6 tests)
  - Total: 25 new unit tests added
- Added ERB templates (class.erb and method.erb) to generate Minitest test code skeleton
- Implemented test generation supporting various class/module nesting patterns:
  - Simple classes: `class User`
  - Regular nested classes: `class User; class Profile; end; end`
  - Compact nested classes: `class User::Profile`
  - Deep nested classes: `class App::User::Profile` (supports any depth)
  - Mixed nested patterns: `class App::User; class Profile; end; end`
  - Double compact nested: `class App::Model; class User::Profile; end; end`
  - Triple nested with mixed patterns: `class App::Model; class Admin::User; class Profile; end; end; end`
  - Compact nested modules: `module User::Updator`
- Generated test files include properly indented method definitions with skip statements
- Test methods are separated by blank lines for better readability
- Implemented CLI with OptionParser support
  - `-o, --output FILE`: Write output to file instead of stdout
  - `-h, --help`: Display help message
  - `-v, --version`: Display version information
  - File argument support: `igata file.rb`
  - Stdin support: `cat file.rb | igata`
- Added CLI regression tests (test/cli_test.rb) covering all command-line options and input methods

### Changed

- Reorganized project structure for multi-formatter support:
  - Moved templates to `lib/igata/formatters/templates/minitest/`
  - Reorganized fixtures to `test/fixtures/formatters/minitest/integration/`
  - Separated tests into `test/integration/` and `test/unit/`
- Refactored code generation to use Formatter pattern:
  - `Igata` class delegates to formatter for code generation
  - Accepts `formatter:` parameter (default: `:minitest`)
  - Supports custom formatter classes
- Refactored AST analysis logic into Extractor pattern for better separation of concerns
- Introduced Value Objects (`ConstantPath`, `MethodInfo`) using `Data.define` for immutable data structures
- Implemented recursive traversal for deeply nested class/module definitions
- AST extraction is now handled by specialized extractors:
  - `Extractors::ConstantPath`: Extracts full constant paths from nested structures
  - `Extractors::MethodNames`: Extracts method information from class nodes

### Fixed

- Fixed empty class handling in Extractors:
  - `ConstantPath` now handles BeginNode (empty classes) correctly
  - `MethodNames` returns empty array for BeginNode instead of raising error

## [0.1.0] - 2025-10-25

- Initial release
