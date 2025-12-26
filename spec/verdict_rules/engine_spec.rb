RSpec.describe VerdictRules::Engine do
  describe "#initialize" do
    it "pode ser instanciado sem argumentos" do
      expect { described_class.new }.not_to raise_error
    end

    it "pode ser instanciado com um contexto" do
      context = { user_age: 25 , country: "BR" }

      expect { described_class.new(context) }.not_to raise_error
    end
  end

  describe "#context" do
    context "quando inicializado sem contexto" do
      it "retorna um hash vazio" do
        engine = described_class.new

        expect(engine.context).to eq({})
      end
    end

    context "quando inicializado com contexto" do
      it "armazena o contexto fornecido" do
        context = { user_age: 25, country: "BR" }
        engine = described_class.new(context)

        expect(engine.context).to eq(context)
      end

      it "não permite modificação externa do contexto" do
        original_context = { user_age: 25 }
        engine = described_class.new(original_context)
        
        # Tenta modificar o contexto original
        original_context[:user_age] = 30
        
        # O contexto interno não deve mudar
        expect(engine.context[:user_age]).to eq(25)
      end
    end

    context "quando recebe tipos diferentes de dados" do
      it "aceita strings como valores" do
        context = { name: "Tibério", email: "tiberio@example.com" }
        engine = described_class.new(context)
        
        expect(engine.context[:name]).to eq("Tibério")
      end

      it "aceita números como valores" do
        context = { age: 25, balance: 1000.50 }
        engine = described_class.new(context)
        
        expect(engine.context[:age]).to eq(25)
        expect(engine.context[:balance]).to eq(1000.50)
      end

      it "aceita arrays como valores" do
        context = { tags: ["premium", "verificado"] }
        engine = described_class.new(context)
        
        expect(engine.context[:tags]).to eq(["premium", "verificado"])
      end

      it "aceita hashes aninhados como valores" do
        context = { 
          user: { 
            name: "Tibério", 
            address: { city: "Ceará" } 
          } 
        }
        engine = described_class.new(context)
        
        expect(engine.context[:user][:name]).to eq("Tibério")
        expect(engine.context[:user][:address][:city]).to eq("Ceará")
      end
    end
  end

  describe "imutabilidade do contexto" do
    it "não permite adicionar chaves após inicialização" do
      engine = described_class.new({ user_age: 25 })
      
      expect { 
        engine.context[:new_key] = "value" 
      }.to raise_error(FrozenError)
    end

    it "não permite modificar valores após inicialização" do
      engine = described_class.new({ user_age: 25 })
      
      expect { 
        engine.context[:user_age] = 30 
      }.to raise_error(FrozenError)
    end
  end

  describe "gerenciamento de regras"do
    describe "#add_rule" do
      it "adiciona uma regra à engine" do
        engine = described_class.new
        rule = VerdictRules::Rule.new(
          condition: ->(ctx) { ctx[:age] >= 18 },
          action: :approve
        )

        expect { engine.add_rule(rule) }.not_to raise_error
      end

      it "aceita múltiplas regras" do
        engine = described_class.new
        age_rule = VerdictRules::Rule.new(
          condition: ->(ctx) { ctx[:age] >= 18 },
          action: :approve
        )
        verified_rule = VerdictRules::Rule.new(
          condition: ->(ctx) { ctx[:verified] == true },
          action: :grant_access
        )

        engine.add_rule(age_rule)
        engine.add_rule(verified_rule)

        expect(engine.rules.size).to eq(2)
      end

      it "retorna self para permitir chainig" do
        engine = described_class.new
        rule = VerdictRules::Rule.new(
          condition: ->(ctx) { true },
          action: :approve
        )

        result = engine.add_rule(rule)
        expect(result).to be(engine)
      end
    end

    describe "#rules" do
      it "retorna array vazio quando não há regras" do
        engine = described_class.new

        expect(engine.rules).to eq([])
      end

      it "retorna array com as regras adicionadas" do
        engine = described_class.new
        rule = VerdictRules::Rule.new(
          condition: ->(ctx) { true },
          action: :approve
        )

        engine.add_rule(rule)
        expect(engine.rules).to be([rule])
      end
    end

    describe "#evaluate" do
      it "retorna nil quando não há regras" do
        engine = described_class.new({ age: 25 })

        expect(engine.evaluate).to be_nil
      end

      it "retorna a action da primeira regra que satisfazer a condição" do
        engine = described_class.new({ age: 25, country: "BR"})

        engine.add_rule(
          VerdictRules::Rule.new(
            condition: ->(ctx) { ctx[:age] >= 18 },
            action: :approve
          )
        )

        expect(engine.evaluate).to eq(:approve)
      end

      it "retorna nil quando nenhuma regra bater" do
        engine = described_class.new({ age: 16 })
      
        engine.add_rule(
          VerdictRules::Rule.new(
            condition: ->(ctx) { ctx[:age] >= 18 },
            action: :approve
          )
        )
        
        expect(engine.evaluate).to be_nil
      end

      it "avalia apenas a primeira regra que bater" do
        engine = described_class.new({ age: 25, verified: true })
      
        engine.add_rule(
          VerdictRules::Rule.new(
            condition: ->(ctx) { ctx[:age] >= 18 },
            action: :approve_by_age
          )
        )
        
        engine.add_rule(
          VerdictRules::Rule.new(
            condition: ->(ctx) { ctx[:verified] == true },
            action: :approve_by_verification
          )
        )
        
        # Deve retornar a primeira que bater
        expect(engine.evaluate).to eq(:approve_by_age)
      end

      context "com múltiplas regras" do
        it "avalia na ordem em que foram adicionadas" do
          engine = described_class.new({ score: 75 })
        
          engine.add_rule(
            VerdictRules::Rule.new(
              condition: ->(ctx) { ctx[:score] >= 90 },
              action: :excellent
            )
          )
          
          engine.add_rule(
            VerdictRules::Rule.new(
              condition: ->(ctx) { ctx[:score] >= 70 },
              action: :good
            )
          )
          
          engine.add_rule(
            VerdictRules::Rule.new(
              condition: ->(ctx) { ctx[:score] >= 50 },
              action: :average
            )
          )
          
          expect(engine.evaluate).to eq(:good)
        end
      end
    end
  end
end
