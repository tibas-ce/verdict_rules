# frozen_string_literal: true

if ENV.fetch("COVERAGE", "true") == "true"
  require "simplecov"
  SimpleCov.start do
    # Código que NÃO deve contar no coverage
    add_filter "/spec/"
    add_filter "/.bundle"

    # Agrupa o relatórios
    add_group "Bibliotecas", "/lib/"
    add_group "Executáveis", "/bin/"

    # Coverage mínimo aceitável
    minimum_coverage 90

    # Define a cobertura mínima por arquivo
    minimum_coverage_by_file 80

    # Formatos de report
    formatter SimpleCov::Formatter::HTMLFormatter
  end
end

require "verdict_rules"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
