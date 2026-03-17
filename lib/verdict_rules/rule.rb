module VerdictRules
  # Representa uma regra simples composta por:
  # - name: identificador opcional da regra (útil para debug e logging)
  # - uma condition (Proc que recebe o contexto e retorna true/false)
  # - uma action (valor retornado quando a condição é satisfeita)
  # - priority: número usado para ordenar regras (quanto maior, maior prioridade)
  class Rule
    attr_reader :name, :condition, :action, :priority

    def initialize(name: nil, condition:, action:, priority: 0)
      validate_arguments!(name, condition, action, priority)
      
      @name = normalize_name(name)
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

    # Representação em hash (útil para logging e serialização)
    def to_h
      {
        name: name,
        priority: priority,
        action: action
      }
    end

    # Representação legível para debugging
    def inspect
      if name
        "#<VerdictRules::Rule name=#{name.inspect} priority=#{priority} action=#{action.inspect}>"
      else
        "#<VerdictRules::Rule priority=#{priority} action=#{action.inspect}>"
      end
    end

    private

    # Valida os argumentos da regra.
    # Regras de design:
    # - condition deve ser um Proc
    # - action é obrigatória
    # - priority deve ser numérica (pode ser negativa)
    def validate_arguments!(name, condition, action, priority)
      validate_name!(name) unless name.nil?
      raise ArgumentError, "condition" if condition.nil?
      raise ArgumentError, "action" if action.nil?
      raise ArgumentError, "condition must be a Proc" unless condition.is_a?(Proc)
      raise ArgumentError, "priority must be a number" unless priority.is_a?(Numeric)
    end

    def validate_name!(name)
      unless name.is_a?(Symbol) || name.is_a?(String)
        raise ArgumentError, "name must be a symbol or string"
      end

      if name.is_a?(String) && name.strip.empty?
        raise ArgumentError, "name cannot be empty"
      end
    end

    def normalize_name(name)
      return nil if name.nil?
      name = name.strip if name.is_a?(String)
      name.to_sym
    end
  end
end
