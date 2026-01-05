module VerdictRules
  # Representa o resultado da avaliação de uma Rule Engine. Encapsula o valor retornado e a regra que foi satisfeita (se houver)
  class Result
    attr_reader :value, :matched_rule
    
    def initialize(value:, matched_rule:)
      @value = value
      @matched_rule = matched_rule
    end

    # Indica se alguma regra foi satisfeita
    def matched?
      !matched_rule.nil?
    end

    # Retorna representação em hash do resultado da avaliação
    def to_h
      {
        value: value,
        matched: matched?,
        matched_rule: matched_rule
      }
    end

    # Representação legível para debugging
    def inspect
      if matched?
        "#<VerdictRules::Result value=#{value.inspect} matched=true rule=#{matched_rule.object_id}>"
      else
        "#<VerdictRules::Result value=#{value.inspect} matched=false>"
      end
    end

    # Define igualdade semâtica entre dois Results
    def ==(other)
      return false unless other.is_a?(Result)

      value == other.value && matched_rule == other.matched_rule
    end

    alias eql? ==
  end
end
