## [Unreleased]

### Added

- Introduced Formatter architecture for supporting multiple test frameworks:
  - `Formatters::Base`: Abstract base class for all formatters
  - `Formatters::Minitest`: Minitest-specific formatter implementation
  - `MethodNotOverriddenError`: Custom error for abstract method violations
  - Separated `Igata::Error` into dedicated file
- Added CLI formatter option:
  - `-f, --formatter FORMATTER`: Specify test framework formatter (currently: minitest)
- Added branch analysis functionality:
  - `BranchInfo` value object: Stores branch information (type, condition)
  - `BranchAnalyzer` extractor: Detects if/unless/case statements in methods
  - `MethodInfo` now includes `branches` field for branch information
  - Minitest template generates branch comments (e.g., `# Branches: if, unless`)
- Added comparison analysis functionality:
  - `ComparisonInfo` value object: Stores comparison information (operator, left, right, context)
  - `ComparisonAnalyzer` extractor: Detects comparison operators (>=, <=, >, <, ==, !=) in methods
  - `MethodInfo` now includes `comparisons` field for comparison information
  - Minitest template generates comparison comments (e.g., `# Comparisons: >= (age >= 18)`)
  - Supports multiple comparisons with AND/OR operators (e.g., `value >= 0 && value <= 150`)
  - Detects comparisons in various contexts: direct returns, if/unless conditions, nested expressions
  - Handles different expression types: local variables, instance variables, integers, strings, symbols
- Added comprehensive unit tests:
  - Extractor tests: `ConstantPath` (10 tests), `MethodNames` (6 tests), `BranchAnalyzer` (6 tests), `ComparisonAnalyzer` (6 tests)
  - Formatter tests: `Base` (3 tests), `Minitest` (6 tests)
  - Total: 37 new unit tests added
- Added integration tests for branch analysis:
  - `class_with_branches` test fixture with if/unless/case statements
  - 4 integration tests verifying branch comment generation
- Added integration tests for comparison analysis:
  - `class_with_comparisons` test fixture with various comparison operators
  - 6 integration tests verifying comparison comment generation
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
  - Reorganized fixtures to `test/fixtures/integration/minitest/`
  - Test type (integration/unit) is now the primary hierarchy, formatter (minitest) is secondary
  - Separated tests into `test/integration/` and `test/unit/`
- Refactored code generation to use Formatter pattern:
  - `Igata` class delegates to formatter for code generation
  - Accepts `formatter:` parameter (default: `:minitest`)
  - Supports custom formatter classes
- Refactored AST analysis logic into Extractor pattern for better separation of concerns
- Introduced Value Objects (`ConstantPath`, `MethodInfo`, `BranchInfo`) using `Data.define` for immutable data structures
- Implemented recursive traversal for deeply nested class/module definitions
- AST extraction is now handled by specialized extractors:
  - `Extractors::ConstantPath`: Extracts full constant paths from nested structures
  - `Extractors::MethodNames`: Extracts method information from class nodes
  - `Extractors::BranchAnalyzer`: Analyzes control flow branches in methods
  - `Extractors::ComparisonAnalyzer`: Analyzes comparison operators in methods
- `MethodNames` extractor now automatically runs `BranchAnalyzer` and `ComparisonAnalyzer` for each method

### Fixed

- Fixed empty class handling in Extractors:
  - `ConstantPath` now handles BeginNode (empty classes) correctly
  - `MethodNames` returns empty array for BeginNode instead of raising error

## [0.1.0] - 2025-10-25

- Initial release
