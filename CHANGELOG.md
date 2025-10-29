## [Unreleased]

### Changed

- Updated Kanayago dependency from ~> 0.3.0 to ~> 0.4.0 for improved method parameter information support

### Fixed

- Fixed BlockNode and BeginNode handling for real-world Ruby code
  - Fixed BlockNode handling: When `require` statements or constants appear before class definitions, the AST creates a BlockNode wrapper
    - Added `find_class_node` method in `Extractors::ConstantPath` to search for ClassNode within BlockNode
    - Example: `backup_service.rb` with `require 'zip'` at the top
  - Fixed BeginNode handling: Empty classes or classes with special structures create BeginNode that lack the `find` method
    - Added `respond_to?` checks in `find_deepest_class_node` to safely handle these cases
    - Returns `nil` for BeginNode structures
  - Added test cases for both scenarios (`class_with_require` and `class_with_no_methods`) to prevent regression
  - Verified with all 69 Mastodon service classes (100% success rate)
- Fixed StringNode value extraction to use `ptr` instead of `val` in `BranchAnalyzer` and `ComparisonAnalyzer`
  - Kanayago 0.4.0 changed the API: string values are now stored in `ptr` field instead of `val`
  - Added integration tests for string literal comparisons and branches to prevent regression

## [0.2.1] - 2025-10-26

### Added

- Added Kanayago (~> 0.3.0) as runtime dependency to ensure automatic installation

### Fixed

- Fixed LoadError when Kanayago is not manually installed by adding it as gemspec dependency

## [0.2.0] - 2025-10-26

### Added

- Introduced Formatter architecture for supporting multiple test frameworks:
  - `Formatters::Base`: Abstract base class for all formatters
  - `Formatters::Minitest`: Minitest-specific formatter implementation
  - `Formatters::RSpec`: RSpec-specific formatter implementation
  - `MethodNotOverriddenError`: Custom error for abstract method violations
  - Separated `Igata::Error` into dedicated file
- Added CLI formatter option:
  - `-f, --formatter FORMATTER`: Specify test framework formatter (minitest or rspec)
- Added RSpec support:
  - RSpec formatter generates `describe` and `it` blocks
  - RSpec templates (class.erb and method.erb) for RSpec-style test generation
  - Supports all branch and comparison analysis features in RSpec format
  - Branch and comparison comments in RSpec tests (e.g., `# Branches: if (value > 0)`)
  - Unit tests for RSpec formatter (6 tests)
  - Integration tests for RSpec formatter (3 tests)
- Added branch analysis functionality:
  - `BranchInfo` value object: Stores branch information (type, condition)
  - `BranchAnalyzer` extractor: Detects if/unless/case statements in methods
  - `MethodInfo` now includes `branches` field for branch information
  - Minitest template generates branch comments with condition information (e.g., `# Branches: if (age >= 18), unless (user.valid?)`)
  - Extracts condition expressions for if/unless/case statements
  - Handles method calls, comparisons, and variable references in conditions
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
