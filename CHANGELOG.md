# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-03-23

### Added
- Initial release
- Core rule engine with context management
- Priority-based rule resolution
- Explainable results with Result object
- Expressive DSL for rule definition
- Named rules for better debugging and logging
- Immutable context for thread safety
- 100% test coverage
- Comprehensive examples
- Full documentation in Portuguese

### Features
- `VerdictRules::Engine` - Main engine for rule evaluation
- `VerdictRules::Rule` - Individual rule with condition, action, and priority
- `VerdictRules::Result` - Rich result object explaining outcomes
- `VerdictRules::RuleBuilder` - DSL builder for clean syntax
- Support for complex nested contexts
- Priority system with stable sort
- Method chaining support

[Unreleased]: https://github.com/tibas-ce/verdict_rules/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/tibas-ce/verdict_rules/releases/tag/v0.1.0
