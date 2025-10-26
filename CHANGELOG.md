## [Unreleased]

### Added

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

### Changed

- Refactored AST analysis logic into Extractor pattern for better separation of concerns
- Introduced Value Objects (`ConstantPath`, `MethodInfo`) using `Data.define` for immutable data structures
- Implemented recursive traversal for deeply nested class/module definitions
- AST extraction is now handled by specialized extractors:
  - `Extractors::ConstantPath`: Extracts full constant paths from nested structures
  - `Extractors::MethodNames`: Extracts method information from class nodes

## [0.1.0] - 2025-10-25

- Initial release
