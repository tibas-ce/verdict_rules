module VerdictRules 
  class RuleBuilder
    # Builder responsável por construir instâncias de Rule a partir da DSL
    # Encapsula validações e evita que a Engine lide com estado parcial
    # Usado internamente pelo Engine#rule e Engine#rules
    def initialize(priority: 0)  
      @priority = priority
      @condition = nil
      @action = nil
    end

    # Define a condição da regra
    # O bloco a ser chamado posteriormente com o contexto da Engine
    # Exibe bloco para garantir previsibilidade do DSL  
    def when_condition(&block)
      raise ArgumentError, "block required for when_condition" unless block_given?

      @condition = block
    end

    # Define a ação da regra
    # Aceita qualquer valor (symbol, string, hash, etc)
    def then_action(value)
      @action = value
    end

    # Constrói e retorna uma instância de Rule
    # Garante que a DSL foi definida corretamente amtes da criação
    # Falha cedo caso condition ou action estejam ausentes
    def build
      validate! 

      Rule.new(
        condition: @condition,
        action: @action,
        priority: @priority
      )
    end

    private

    def validate!
      raise ArgumentError, "condition is required (use when_condition)" if @condition.nil?
      raise ArgumentError, "action is required (use then_action)" if @action.nil?
    end
  end
  
end
