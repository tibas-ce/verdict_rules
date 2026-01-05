RSpec.describe VerdictRules::Result do
  describe "#initialize" do
    it "pode ser criado com valor e matched_rule" do
      rule = VerdictRules::Rule.new(
        condition: ->(ctx) { ctx[:age] >= 18 },
        action: :approve
      )
      
      expect {
        described_class.new(value: :approve, matched_rule: rule)
      }.not_to raise_error
    end

    it "pode ser criado sem regra correspondente" do
      expect {
        described_class.new(value: nil, matched_rule: nil)
      }.not_to raise_error
    end
  end

  describe "#value" do
    it "retorna o valor do resultado" do
      rule = VerdictRules::Rule.new(
        condition: ->(ctx) { true },
        action: :approve
      )
      
      result = described_class.new(value: :approve, matched_rule: rule)
      expect(result.value).to eq(:approve)
    end

    it "pode retornar nil quando nenhuma regra bater" do
      result = described_class.new(value: nil, matched_rule: nil)
      expect(result.value).to be_nil
    end
  end

  describe "#matched_rule" do
    it "retorna a regra que foi aplicada" do
      rule = VerdictRules::Rule.new(
        condition: ->(ctx) { true },
        action: :approve
      )
      
      result = described_class.new(value: :approve, matched_rule: rule)
      expect(result.matched_rule).to eq(rule)
    end

    it "retorna nil quando nenhuma regra bater" do
      result = described_class.new(value: nil, matched_rule: nil)
      expect(result.matched_rule).to be_nil
    end
  end

  describe "#matched?" do
    it "retorna true quando uma regra bateu" do
      rule = VerdictRules::Rule.new(
        condition: ->(ctx) { true },
        action: :approve
      )
      
      result = described_class.new(value: :approve, matched_rule: rule)
      expect(result.matched?).to be true
    end

    it "retorna false quando nenhuma regra bateu" do
      result = described_class.new(value: nil, matched_rule: nil)
      expect(result.matched?).to be false
    end
  end

  describe "#to_h" do
    context "quando uma regra bateu" do
      it "retorna hash com todas as informações" do
        rule = VerdictRules::Rule.new(
          condition: ->(ctx) { ctx[:age] >= 18 },
          action: :approve
        )
        
        result = described_class.new(value: :approve, matched_rule: rule)
        hash = result.to_h
        
        expect(hash).to include(
          value: :approve,
          matched: true,
          matched_rule: rule
        )
      end
    end

    context "quando nenhuma regra bateu" do
      it "retorna hash indicando que não houve match" do
        result = described_class.new(value: nil, matched_rule: nil)
        hash = result.to_h
        
        expect(hash).to include(
          value: nil,
          matched: false,
          matched_rule: nil
        )
      end
    end
  end

  describe "#inspect" do
    it "retorna representação legível do resultado" do
      rule = VerdictRules::Rule.new(
        condition: ->(ctx) { ctx[:age] >= 18 },
        action: :approve
      )
      
      result = described_class.new(value: :approve, matched_rule: rule)
      inspection = result.inspect
      
      expect(inspection).to include("Result")
      expect(inspection).to include("approve")
      expect(inspection).to include("matched=true")
    end

    it "indica quando nenhuma regra bateu" do
      result = described_class.new(value: nil, matched_rule: nil)
      inspection = result.inspect
      
      expect(inspection).to include("Result")
      expect(inspection).to include("matched=false")
    end
  end

  describe "comparação e igualdade" do
    it "considera dois Results iguais se têm mesmo value e matched_rule" do
      rule = VerdictRules::Rule.new(
        condition: ->(ctx) { true },
        action: :approve
      )
      
      result1 = described_class.new(value: :approve, matched_rule: rule)
      result2 = described_class.new(value: :approve, matched_rule: rule)
      
      expect(result1).to eq(result2)
    end

    it "considera dois Results diferentes se têm values diferentes" do
      rule = VerdictRules::Rule.new(
        condition: ->(ctx) { true },
        action: :approve
      )
      
      result1 = described_class.new(value: :approve, matched_rule: rule)
      result2 = described_class.new(value: :reject, matched_rule: rule)
      
      expect(result1).not_to eq(result2)
    end
  end
end