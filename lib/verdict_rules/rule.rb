module VerdictRules
  # Representa uma regra simples composta por:
  # - uma condition (Proc que recebe o contexto e retorna true/false)
  # - uma action (valor retornado quando a condição é satisfeita)
  class Rule
    attr_reader :condition,:action

    def initialize(condition:, action:)
      validate_arguments(condition, action)
      
      @condition = condition
      @action = action
    end

    # Avalia a regra contra um contexto
    # Retorna a action se a condition for true, nil caso contrário
    def evaluate(context)
      return action if matches?(context)
      nil
    end

    # Verifica se a condição é satisfeita pelo contexto
    def matches?(context)
      condition.call(context)
    end

    private

    def validate_arguments(condition, action)
      raise ArgumentError, "condition" if condition.nil?
      raise ArgumentError, "action" if action.nil?
      raise ArgumentError, "condition must be a Proc" unless condition.is_a?(Proc)
    end
  end
end
