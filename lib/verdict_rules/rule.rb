module VerdictRules
  # Representa uma regra simples composta por:
  # - uma condition (Proc que recebe o contexto e retorna true/false)
  # - uma action (valor retornado quando a condição é satisfeita)
  # - priority: número usado para ordenar regras (quanto maior, maior prioridade)
  class Rule
    attr_reader :condition,:action, :priority

    def initialize(condition:, action:, priority: 0)
      validate_arguments(condition, action, priority)
      
      @condition = condition
      @action = action
      @priority = priority
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

    # Valida os argumentos da regra.
    # Regras de design:
    # - condition deve ser um Proc
    # - action é obrigatória
    # - priority deve ser numérica (pode ser negativa)
    def validate_arguments(condition, action, priority)
      raise ArgumentError, "condition" if condition.nil?
      raise ArgumentError, "action" if action.nil?
      raise ArgumentError, "condition must be a Proc" unless condition.is_a?(Proc)
      raise ArgumentError, "priority must be a number" unless priority.is_a?(Numeric)
    end
  end
end
