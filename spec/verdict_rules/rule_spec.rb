RSpec.describe VerdictRules::Rule do
  describe "#initialize" do
    it "pode ser criada com condition e action" do
      condition = ->(ctx) { ctx[:age] >= 18 }
      action = :approve
      
      expect {
        described_class.new(condition: condition, action: action)
      }.not_to raise_error
    end

    it "exige que uma condition seja fornecida" do
      expect {
        described_class.new(action: :approve)
      }.to raise_error(ArgumentError, /condition/)
    end

    it " exige que uma action seja fornecida" do
      condition = ->(ctx) { ctx[:age] >= 18 }
      
      expect {
        described_class.new(condition: condition)
      }.to raise_error(ArgumentError, /action/)
    end

    it "exige que condition seja um Proc" do
      expect {
        described_class.new(condition: "not a proc", action: :approve)
      }.to raise_error(ArgumentError, /condition must be a Proc/)
    end
  end

  describe "#evaluate" do
    context "quando a condição retorna true" do
      it "retorna a action" do
        rule = described_class.new(
          condition: ->(ctx) { ctx[:age] >= 18 },
          action: :approve
        )
        
        context = { age: 25 }
        result = rule.evaluate(context)
        
        expect(result).to eq(:approve)
      end
    end

    context "quando a condição retorna false" do
      it "retorna nil" do
        rule = described_class.new(
          condition: ->(ctx) { ctx[:age] >= 18 },
          action: :approve
        )
        
        context = { age: 16 }
        result = rule.evaluate(context)
        
        expect(result).to be_nil
      end
    end

    context "com diferentes tipos de condições" do
      it "avalia igualdade de strings" do
        rule = described_class.new(
          condition: ->(ctx) { ctx[:country] == "BR" },
          action: :allow_brl_payment
        )
        
        expect(rule.evaluate({ country: "BR" })).to eq(:allow_brl_payment)
        expect(rule.evaluate({ country: "US" })).to be_nil
      end

      it "avalia inclusão em array" do
        rule = described_class.new(
          condition: ->(ctx) { ["premium", "gold"].include?(ctx[:tier]) },
          action: :grant_access
        )

        expect(rule.evaluate({ tier: "premium" })).to eq(:grant_access)
        expect(rule.evaluate({ tier: "basic" })).to be_nil
      end

      it "avalia múltiplas condições combinadas" do
        rule = described_class.new(
          condition: ->(ctx) { ctx[:age] >= 18 && ctx[:verified] == true },
          action: :full_access
        )

        expect(rule.evaluate({ age: 25, verified: true })).to eq(:full_access)
        expect(rule.evaluate({ age: 25, verified: false })).to be_nil
        expect(rule.evaluate({ age: 16, verified: true })).to be_nil
      end
    end

    context "com diferentes tipos de actions" do
      it "retorna action como symbol" do
        rule = described_class.new(
          condition: ->(ctx) { ctx[:approved] },
          action: :approve
        )

        expect(rule.evaluate({ approved: true })).to eq(:approve)
      end

      it "retorna action como string" do
        rule = described_class.new(
          condition: ->(ctx) { ctx[:approved] },
          action: "approve"
        )

        expect(rule.evaluate({ approved: true })).to eq("approve")
      end

      it "retorna action como hash" do
        rule = described_class.new(
          condition: ->(ctx) { ctx[:approved] },
          action: { status: :approve, reason: "All checks passed" }
        )

        expect(rule.evaluate({ approved: true })).to eq( { status: :approve, reason: "All checks passed" } )
      end
    end
  end

  describe "#matches" do
    it "retorna true quando a condição é satisfeita" do
      rule = described_class.new(
        condition: ->(ctx) { ctx[:age] >= 18 },
        action: :approve
      )
      
      expect(rule.matches?({ age: 25 })).to be true
    end

    it "retorna false quando a condição não é satisfeita" do
      rule = described_class.new(
        condition: ->(ctx) { ctx[:age] >= 18 },
        action: :approve
      )

      expect(rule.matches?({ age: 16 })).to be false
    end
  end
end