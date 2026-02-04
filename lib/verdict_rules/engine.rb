# Engine é responsável por:
# - armazenar o contexto de avaliação
# - gerenciar a lista de regras
# - avaliar as regras em ordem e retornar a primeira action válida
# O contexto é fornecido na inicialização e pertence à Engine.

module VerdictRules
  class Engine
    attr_reader :context, :rules

    def initialize(context = {})
      @context = deep_freeze(context.dup)
      @rules = []
    end

    # Adiciona uma regra à engine
    # Regras são automaticamente ordenadas por prioridade (maior primeiro)
    # Em caso de empate, ordem de inserção é mantida (stable sort)
    # Retorna self para permitir chaining
    def add_rule(rule)
      @rules << rule
      sort_rules!
      self
    end

    # DSL: Define uma única regra usando bloco
    # Exemplo:
    #   engine.rule(priority: 10) do
    #     when_condition { |ctx| ctx[:age] >= 18 }
    #     then_action :approve
    #   end
    # Retorna self para permitir chaining
    def rule(priority: 0, &block)
      raise ArgumentError, "block required" unless block_given?

      builder = RuleBuilder.new(priority: priority)
      builder.instance_eval(&block)
      add_rule(builder.build)

      self
    end

    # DSL: Define múltiplas regras em um bloco
    # Exemplo:
    #   engine.rules do
    #     rule(priority: 10) do
    #       when_condition { |ctx| ctx[:age] >= 18 }
    #       then_action :approve
    #     end
    #     
    #     rule(priority: 5) do
    #       when_condition { |ctx| ctx[:verified] }
    #       then_action :grant_access
    #     end
    #   end
    # Retorna self para permitir chaining
    def rules(&block)
      raise ArgumentError, "block required" unless block_given?

      instance_eval(&block)
      self
    end

    # Avalia as regras utilizando o contexto interno da Engine.
    # Regras são avaliadas em ordem de prioridade (maior primeiro)
    # Decisão de design:
    # - O contexto é definido na inicialização da Engine
    # - O método `evaluate` não recebe argumentos
    # - Cada regra recebe o contexto da Engine durante a avaliação
    # Retorna um Result contendo:
    # - value: a action da primeira regra que bater (ou nil)
    # - matched_rule: a regra que bateu (ou nil)
    # Isso mantém a API simples e evita múltiplas formas de fornecer contexto.
    def evaluate
      rules.each do |rule|
        action = rule.evaluate(context)

        unless action.nil?
          return Result.new(value: action, matched_rule: rule)
        end
      end

      # Nenhuma regra bateu
      Result.new(value: nil, matched_rule: nil)
    end

    private

    # Congela recursivamente hashes e arrays para garantir a imutabilidade do contexto após a inicialização
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

    # Ordena regras por prioridade (maior primeiro)
    # Em caso de empate, preserva a ordem de inserção para garantir previsibilidade na avaliação.
    def sort_rules!
      @rules = @rules.sort_by.with_index { |rule, index| [-rule.priority, index] }
    end
  end
end