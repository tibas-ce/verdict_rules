module VerdictRules
  class Engine
    attr_reader :context

    def initialize(context = {})
      @context = deep_freeze(context.dup)
    end

    private

    #  congela recursivamente hashes e arrays para garantir que o contexto não possa ser alterado após a inicialização
    def deep_freeze(object)
      case object
      when Hash
        object.each { |key, value| deep_freeze(value) }
        object.freeze
      when Array
        object.each { |value| deep_freeze(value) }
        object.freeze
      else
        object.freeze
      end
    end
  end
end