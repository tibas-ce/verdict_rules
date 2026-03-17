RSpec.describe VerdictRules::Rule do
  describe "prioridade" do
    it "aceita priority com argumento opcional" do
      expect {
        described_class.new(
          condition: ->(ctx) { true },
          action: :approve,
          priority: 10
        )
    }.not_to raise_error
    end

    it "usa prioridade padrão 0 quando não fornecida" do
      rule = described_class.new(
          condition: ->(ctx) { true },
          action: :approve
        )

      expect(rule.priority).to eq(0)
    end

    it "armazena a prioridade fornecida" do
      rule = described_class.new(
          condition: ->(ctx) { true },
          action: :approve,
          priority: 100
        )

      expect(rule.priority).to eq(100)
    end

    it "aceita prioridades negativas" do
      rule = described_class.new(
          condition: ->(ctx) { true },
          action: :approve,
          priority: -5
        )

      expect(rule.priority).to eq(-5)
    end

    it "valida que priority seja um número" do
      expect {
        described_class.new(
          condition: ->(ctx) { true },
          action: :approve,
          priority: "high"
        )
    }.to raise_error(ArgumentError, /priority must be a number/)
    end
  end

  describe "#name" do
    it "armazena o nome fornecido" do
      rule = described_class.new(
        name: :check_age,
        condition: ->(ctx) { true },
        action: :approve
      )
      
      expect(rule.name).to eq(:check_age)
    end

    it "retorna nil quando name não é fornecido" do
      rule = described_class.new(
        condition: ->(ctx) { true },
        action: :approve
      )
      
      expect(rule.name).to be_nil
    end

    it "aceita name como symbol" do
      rule = described_class.new(
        name: :my_rule,
        condition: ->(ctx) { true },
        action: :approve
      )
      
      expect(rule.name).to eq(:my_rule)
    end

    it "aceita name como string e converte para symbol" do
      rule = described_class.new(
        name: "my_rule",
        condition: ->(ctx) { true },
        action: :approve
      )
      
      expect(rule.name).to eq(:my_rule)
    end

    it "valida que name não seja vazio quando fornecido" do
      expect {
        described_class.new(
          name: "",
          condition: ->(ctx) { true },
          action: :approve
        )
      }.to raise_error(ArgumentError, /name cannot be empty/)
    end

    it "valida que name não seja apenas espaços em branco" do
      expect {
      described_class.new(
          name: "   ",
          condition: ->(ctx) { true },
          action: :approve
        )
      }.to raise_error(ArgumentError, /name cannot be empty/)
    end

    it "valida que name seja symbol ou string" do
      expect {
        described_class.new(
          name: 123,
          condition: ->(ctx) { true },
          action: :approve
        )
      }.to raise_error(ArgumentError, /name must be a symbol or string/)
    end
  end

  describe "#inspect" do
    it "inclui o name na representação quando presente" do
      rule = described_class.new(
        name: :check_age,
        condition: ->(ctx) { ctx[:age] >= 18 },
        action: :approve,
        priority: 10
      )
      
      inspection = rule.inspect
      expect(inspection).to include("check_age")
      expect(inspection).to include("priority=10")
    end

    it "não inclui nome quando não fornecido" do
      rule = described_class.new(
        condition: ->(ctx) { ctx[:age] >= 18 },
        action: :approve,
        priority: 10
      )
      
      inspection = rule.inspect
      expect(inspection).to include("priority=10")
      expect(inspection).not_to include("name=")
    end
  end

  describe "#to_h" do
    it "inclui nome no hash quando presente" do
      rule = described_class.new(
        name: :check_age,
        condition: ->(ctx) { true },
        action: :approve,
        priority: 5
      )
      
      hash = rule.to_h
      expect(hash[:name]).to eq(:check_age)
      expect(hash[:priority]).to eq(5)
      expect(hash[:action]).to eq(:approve)
    end

    it "retorna nil para name quando não for fornecido" do
      rule = described_class.new(
        condition: ->(ctx) { true },
        action: :approve
      )
      
      hash = rule.to_h
      expect(hash[:name]).to be_nil
    end
  end

  describe "comparação de prioridades" do
    it "permite comparar regras por prioridade" do
      rule1 = described_class.new(
        condition: ->(ctx) { true },
        action: :approve,
        priority: 1
      )

      rule2 = described_class.new(
        condition: ->(ctx) { true },
        action: :reject,
        priority: 10
      )

      expect(rule2.priority).to be > rule1.priority
    end

    it "regras com a mesma prioridade são equivalentes em ordem" do
      rule1 = described_class.new(
        condition: ->(ctx) { true },
        action: :approve,
        priority: 5
      )

      rule2 = described_class.new(
        condition: ->(ctx) { true },
        action: :reject,
        priority: 5
      )

      expect(rule1.priority).to eq(rule2.priority)
    end
  end

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