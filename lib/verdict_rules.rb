# frozen_string_literal: true

require_relative "verdict_rules/version"
require_relative "verdict_rules/result"
require_relative "verdict_rules/engine"
require_relative "verdict_rules/rule"

module VerdictRules
  class Error < StandardError; end
end
