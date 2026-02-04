# frozen_string_literal: true

require_relative "verdict_rules/version"
require_relative "verdict_rules/result"
require_relative "verdict_rules/rule"
require_relative "verdict_rules/rule_builder"
require_relative "verdict_rules/engine"

module VerdictRules
  class Error < StandardError; end
end
