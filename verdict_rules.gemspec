# frozen_string_literal: true

require_relative "lib/verdict_rules/version"

Gem::Specification.new do |spec|
  spec.name = "verdict_rules"
  spec.version = VerdictRules::VERSION
  spec.authors = ["tiberio_s_ferreira"]
  spec.email = ["tiberio.ferreiracs@gmail.com"]

  spec.summary = "Motor de regras."
  spec.description = "Motor de regras flexíveis para aplicações Ruby"
  spec.homepage = "https://github.com/tibas-ce/string_magic"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/tibas-ce/verdict_rules"
    spec.metadata["changelog_uri"] = "https://github.com/tibas-ce/verdict_rules/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
