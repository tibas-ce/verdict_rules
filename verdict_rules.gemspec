# frozen_string_literal: true

require_relative "lib/verdict_rules/version"

Gem::Specification.new do |spec|
  spec.name = "verdict_rules"
  spec.version = VerdictRules::VERSION
  spec.authors = ["Tibério dos Santos Ferreira"]
  spec.email = ["tiberio.ferreiracs@gmail.com"]

  spec.summary = "A Ruby gem for defining and evaluating business rules with priorities."
  spec.description = "A gem to define and evaluate business rules with priorities and explainable results."
  spec.homepage = "https://github.com/tibas-ce/verdict_rules"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/tibas-ce/verdict_rules"
  spec.metadata["changelog_uri"] = "https://github.com/tibas-ce/verdict_rules/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "https://github.com/tibas-ce/verdict_rules/issues"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.glob([
    "lib/**/*",
    "LICENSE",
    "README.md",
    "CHANGELOG.md"
  ]).reject { |f| File.directory?(f) }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "simplecov", "~> 0.22"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
