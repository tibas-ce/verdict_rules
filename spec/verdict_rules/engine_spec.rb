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
        expect(engine.rules).to eq([rule])
      end
    end

    describe "ordenação por prioridade" do
      it "ordena regras por prioridade (maior primeiro)" do
        engine = described_class.new({ value: true })

        low_priority = VerdictRules::Rule.new(
          condition: ->(ctx) { ctx[:value] },
          action: :low,
          priority: 1
        )

        medium_priority = VerdictRules::Rule.new(
          condition: ->(ctx) { ctx[:value] },
          action: :medium,
          priority: 5
        )

        high_priority = VerdictRules::Rule.new(
          condition: ->(ctx) { ctx[:value] },
          action: :high,
          priority: 10
        )

        # Adiciona em ordem aleatória
        engine.add_rule(low_priority)
        engine.add_rule(high_priority)
        engine.add_rule(medium_priority)

        # Regras devem estar ordenadas por prioridade (maior primeiro)
        expect(engine.rules[0]).to eq(high_priority)
        expect(engine.rules[1]).to eq(medium_priority)
        expect(engine.rules[2]).to eq(low_priority)
      end

      it "mantém ordem de inserção quando prioridades são iguais" do
        engine = described_class.new({ value: true })

        rule1 = VerdictRules::Rule.new(
          condition: ->(ctx) { ctx[:value] },
          action: :first,
          priority: 5
        )

        rule2 = VerdictRules::Rule.new(
          condition: ->(ctx) { ctx[:value] },
          action: :second,
          priority: 5
        )

        rule3 = VerdictRules::Rule.new(
          condition: ->(ctx) { ctx[:value] },
          action: :third,
          priority: 5
        )

        engine.add_rule(rule1)
        engine.add_rule(rule2)
        engine.add_rule(rule3)

        # Com mesma prioridade, ordem de inserção é mantida
        expect(engine.rules[0]).to eq(rule1)
        expect(engine.rules[1]).to eq(rule2)
        expect(engine.rules[2]).to eq(rule3)
      end
    end

    describe "#evaluate" do
      it "retorna um Result" do
        engine = described_class.new({ age: 25 })
        result = engine.evaluate

        expect(result).to be_a(VerdictRules::Result)
      end

      context "quando não há regras" do
        it "retorna Result com value nil e sem matched_rule" do
          engine = described_class.new({ age: 25 })
          result = engine.evaluate

          expect(result.value).to be_nil
          expect(result.matched?).to be false
          expect(result.matched_rule).to be_nil
        end
      end

      context "quando uma regra bate" do
        it "retorna Result com value e matched_rule" do
          engine = described_class.new({ age: 25, country: "BR" })

          rule = VerdictRules::Rule.new(
            condition: ->(ctx) { ctx[:age] >= 18 },
            action: :approve
          )

          engine.add_rule(rule)
          result = engine.evaluate

          expect(result.value).to eq(:approve)
          expect(result.matched?).to be true
          expect(result.matched_rule).to eq(rule)
        end
      end

      context "quando nenhuma regra bate" do
        it "retorna Result com value nil e sem matched_rule" do
          engine = described_class.new({ age: 16 })

          engine.add_rule(
            VerdictRules::Rule.new(
              condition: ->(ctx) { ctx[:age] >= 18 },
              action: :approve
            )
          )

          result = engine.evaluate

          expect(result.value).to be_nil
          expect(result.matched?).to be false
          expect(result.matched_rule).to be_nil
        end
      end

      context "com múltiplas regras" do
        it "retorna Result da primeira regra que bater" do
          engine = described_class.new({ age: 25, verified: true })
        
          rule1 = VerdictRules::Rule.new(
            condition: ->(ctx) { ctx[:age] >= 18 },
            action: :approve_by_age
          )
          
          rule2 = VerdictRules::Rule.new(
            condition: ->(ctx) { ctx[:verified] == true },
            action: :approve_by_verification
          )
          
          engine.add_rule(rule1)
          engine.add_rule(rule2)
          
          result = engine.evaluate
          
          expect(result.value).to eq(:approve_by_age)
          expect(result.matched_rule).to eq(rule1)
        end

        it "permite identificar qual regra bateu através do Result" do
          engine = described_class.new({ score: 75 })
        
          excellent_rule = VerdictRules::Rule.new(
            condition: ->(ctx) { ctx[:score] >= 90 },
            action: :excellent
          )
          
          good_rule = VerdictRules::Rule.new(
            condition: ->(ctx) { ctx[:score] >= 70 },
            action: :good
          )
          
          average_rule = VerdictRules::Rule.new(
            condition: ->(ctx) { ctx[:score] >= 50 },
            action: :average
          )
          
          engine.add_rule(excellent_rule)
          engine.add_rule(good_rule)
          engine.add_rule(average_rule)
          
          result = engine.evaluate
          
          expect(result.value).to eq(:good)
          expect(result.matched_rule).to eq(good_rule)
          expect(result.matched_rule).not_to eq(excellent_rule)
          expect(result.matched_rule).not_to eq(average_rule)
        end
      end

      context "debugging e auditoria" do
        it "permite inspecionar o resultado para debugging" do
          engine = described_class.new({ age: 25 })

          rule = VerdictRules::Rule.new(
            condition: ->(ctx) { ctx[:age] >= 18 },
            action: :approve
          )

          engine.add_rule(rule)
          result = engine.evaluate

          inspection = result.inspect
          expect(inspection).to include("approve")
          expect(inspection).to include("matched=true")
        end

        it "permite converter resultado para hash para logging" do
          engine = described_class.new({ age: 18 })

          rule = VerdictRules::Rule.new(
            condition: ->(ctx) { ctx[:age] >= 18 },
            action: :approve
          )

          engine.add_rule(rule)
          result = engine.evaluate

          hash = result.to_h
          expect(hash[:value]).to eq(:approve)
          expect(hash[:matched]).to be true
          expect(hash[:matched_rule]).to eq(rule)
        end
      end

      context "com prioridades" do
        it "avalia regra de maior prioridade primeiro" do
          engine = described_class.new({ age: 25, verified: true })

          low_priority_rule = VerdictRules::Rule.new(
            condition: ->(ctx) { ctx[:age] >= 18 },
            action: :approved_by_age,
            priority: 1
          )

          high_priority_rule = VerdictRules::Rule.new(
            condition: ->(ctx) { ctx[:verified] },
            action: :approved_by_verification,
            priority: 10
          )

          # Adiciona em ordem reversa de prioridade
          engine.add_rule(low_priority_rule)
          engine.add_rule(high_priority_rule)

          result = engine.evaluate

          # Regra com maior prioridade vence
          expect(result.value).to eq(:approved_by_verification)
          expect(result.matched_rule).to eq(high_priority_rule)
        end

        it "ignora ordem de inserção quando prioridades são diferentes" do
          engine = described_class.new({ status: :active })

          first_added = VerdictRules::Rule.new(
            condition: ->(ctx) { ctx[:status] == :active },
            action: :first,
            priority: 1
          )

          last_added = VerdictRules::Rule.new(
            condition: ->(ctx) { ctx[:status] == :active },
            action: :last,
            priority: 100
          )

          engine.add_rule(first_added)
          engine.add_rule(last_added)

          result = engine.evaluate

          expect(result.value).to eq(:last)
          expect(result.matched_rule).to eq(last_added)
        end

        it "usa ordem de inserção como critério de desempate" do
          engine = described_class.new({ value: 10 })

          rule1 = VerdictRules::Rule.new(
            condition: ->(ctx) { ctx[:value] >= 5 },
            action: :rule1,
            priority: 5
          )

          rule2 = VerdictRules::Rule.new(
            condition: ->(ctx) { ctx[:value] >= 5 },
            action: :rule2,
            priority: 5
          )

          engine.add_rule(rule1)
          engine.add_rule(rule2)

          result = engine.evaluate

          # Mesma prioridade: primeira adicionada vence
          expect(result.value).to eq(:rule1)
          expect(result.matched_rule).to eq(rule1)
        end

        it "permite prioridades negativas" do
          engine = described_class.new({ value: true })

          negative_priority = VerdictRules::Rule.new(
            condition: ->(ctx) { ctx[:value] },
            action: :negative,
            priority: -10
          )

          zero_priority = VerdictRules::Rule.new(
            condition: ->(ctx) { ctx[:value] },
            action: :zero,
            priority: 0
          )

          positive_priority = VerdictRules::Rule.new(
            condition: ->(ctx) { ctx[:value] },
            action: :positive,
            priority: 10
          )

          engine.add_rule(negative_priority)
          engine.add_rule(zero_priority)
          engine.add_rule(positive_priority)
        
          result = engine.evaluate
        
          expect(result.value).to eq(:positive)
        end

        it "demonstra caso de negócio real: exceções têm prioridade" do
          # Cenário: usuários verificados têm prioridade sobre idade
          engine = described_class.new({ age: 25, verified: true, vip: true })

          # Regra geral (prioridade baixa)
          age_rule = VerdictRules::Rule.new(
            condition: ->(ctx) { ctx[:age] >= 18 },
            action: :standard_access,
            priority: 1
          )

          # Regra especial (prioridade média)
          verified_rule = VerdictRules::Rule.new(
            condition: ->(ctx) { ctx[:verified] },
            action: :verified_access,
            priority: 5
          )

          # Regra VIP (prioridade alta)
          vip_rule = VerdictRules::Rule.new(
            condition: ->(ctx) { ctx[:vip] },
            action: :vip_access,
            priority: 10
          )

          engine.add_rule(age_rule)
          engine.add_rule(verified_rule)
          engine.add_rule(vip_rule)

          result = engine.evaluate

          expect(result.value).to eq(:vip_access)
          expect(result.matched_rule).to eq(vip_rule)
        end
      end
    end
  end
end
