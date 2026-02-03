RSpec.describe "VerdictRules DSL" do
  describe "Engine#rule (singular)" do
    it "permite adicionar regra com bloco" do
      engine = VerdictRules::Engine.new({ age: 25 })

      expect{
        engine.rule do
          when_condition { |ctx| ctx[:age] >= 18 }
          then_action :approve
        end
      }.not_to raise_error
    end

    it "cria e adiciona a regra à engine" do
      engine = VerdictRules::Engine.new({ age: 25 })

      engine.rule do
          when_condition { |ctx| ctx[:age] >= 18 }
          then_action :approve
        end
      
      expect(engine.rules.size).to eq(1)  
      expect(engine.rules.first).to be_a(VerdictRules::Rule)
    end

    it "aceita priority como parâmetro" do
      engine = VerdictRules::Engine.new({ age: 25 })

      engine.rule(priority: 10) do
          when_condition { |ctx| ctx[:age] >= 18 }
          then_action :approve
        end
      
      expect(engine.rules.first.priority).to eq(10) 
    end

    it "usa priority padrão 0 quando não fornecida" do
      engine = VerdictRules::Engine.new({ age: 25 })

      engine.rule do
          when_condition { |ctx| ctx[:age] >= 18 }
          then_action :approve
        end
      
      expect(engine.rules.first.priority).to eq(0) 
    end

    it "retorna self para permitir chaining" do
      engine = VerdictRules::Engine.new({ age: 25 })

      result = engine.rule do
          when_condition { |ctx| ctx[:age] >= 18 }
          theN_action :approve
        end
      
      expect(result).to eq(engine) 
    end
  end

  describe "Engine#rules (plural) batch definition" do
    it "permite definir múltiplas regras em um bloco" do
      engine = VerdictRules::Engine.new({ age: 25, verified: true })
      
      expect {
        engine.rules do
          rule priority: 10 do
            when_condition { |ctx| ctx[:age] >= 18 }
            then_action :approve
          end
          
          rule priority: 5 do
            when_condition { |ctx| ctx[:verified] }
            then_action :grant_access
          end
        end
      }.not_to raise_error
    end

    it "adiciona todas as regras definidas" do
      engine = VerdictRules::Engine.new({ age: 25, verified: true })
      
      engine.rules do
          rule do
            when_condition { |ctx| ctx[:age] >= 18 }
            then_action :approve
          end
          
          rule do
            when_condition { |ctx| ctx[:verified] }
            then_action :grant_access
          end
        end

      expect(engine.rules.size).to eq(2)
    end

    it "retorna self para permitir chaining" do
      engine = VerdictRules::Engine.new({ age: 25 })
      
      result = engine.rules do
          rule do
            when_condition { |ctx| ctx[:age] >= 18 }
            then_action :approve
          end
        end

      expect(result).to eq(engine)
    end
  end

  describe "RuleBuilder" do
    describe "#when_condition" do
      it "aceita um bloco como condição" do
        engine = VerdictRules::Engine.new({ value: true })
        
        engine.rule do
          when_condition { |ctx| ctx[:value] }
          then_action :result
        end
        
        result = engine.evaluate
        expect(result.value).to eq(:result)
      end

      it "valida que um bloco foi fornecido" do
        engine = VerdictRules::Engine.new({ value: true })
        
        expect {
          engine.rule do
            when_condition  # sem bloco
            then_action :result
          end
        }.to raise_error(ArgumentError, /block required/)
      end
    end

    describe "#then_action" do
      it "aceita symbol como action" do
        engine =  VerdictRules::Engine.new({ value: true })

        engine.rule do
          when_condition { |ctx| ctx[:value] }
          then_action :my_action
        end
        
        result = engine.evaluate
        expect(result.value).to eq(:my_action)
      end

      it "aceita string como action" do
        engine = VerdictRules::Engine.new({ value: true })
        
        engine.rule do
          when_condition { |ctx| ctx[:value] }
          then_action "string_action"
        end
        
        result = engine.evaluate
        expect(result.value).to eq("string_action")
      end

      it "aceita hash como action" do
        engine = VerdictRules::Engine.new({ value: true })
        
        engine.rule do
          when_condition { |ctx| ctx[:value] }
          then_action({ status: :approved, reason: "All good" })
        end
        
        result = engine.evaluate
        expect(result.value).to eq({ status: :approved, reason: "All good" })
      end

      it "valida que action foi fornecida" do
        engine = VerdictRules::Engine.new({ value: true })
        
        expect {
          engine.rule do
            when_condition { |ctx| ctx[:value] }
            # sem then_action
          end
        }.to raise_error(ArgumentError, /action is required/)
      end
    end
  end

  describe "integração completa" do
    it "funciona em um caso real de uso" do
      context = { age: 25, country: "BR", verified: true }
      engine = VerdictRules::Engine.new(context)
      
      engine.rules do
        rule priority: 1 do
          when_condition { |ctx| ctx[:age] < 18 }
          then_action :reject_minor
        end
        
        rule priority: 5 do
          when_condition { |ctx| ctx[:age] >= 18 && ctx[:country] == "BR" }
          then_action :approve_brazilian_adult
        end
        
        rule priority: 10 do
          when_condition { |ctx| ctx[:verified] }
          then_action :approve_verified
        end
      end
      
      result = engine.evaluate
      
      expect(result.value).to eq(:approve_verified)
      expect(result.matched_rule.priority).to eq(10)
    end

    it "permite misturar DSL com add_rule tradicional" do
      engine = VerdictRules::Engine.new({ value: 10 })
      
      # Tradicional
      engine.add_rule(
        VerdictRules::Rule.new(
          condition: ->(ctx) { ctx[:value] >= 5 },
          action: :traditional,
          priority: 1
        )
      )
      
      # DSL
      engine.rule(priority: 10) do
        when_condition { |ctx| ctx[:value] >= 5 }
        then_action :dsl
      end
      
      result = engine.evaluate
      
      # DSL rule vence (maior prioridade)
      expect(result.value).to eq(:dsl)
    end
  end

  describe "legibilidade e clareza" do
    it "retorna o código auto-documentável" do
      engine = VerdictRules::Engine.new({ user_type: :premium, active: true })
      
      # Este código deve ser legível como uma regra de negócio
      engine.rule(priority: 10) do
        when_condition { |ctx| ctx[:user_type] == :premium && ctx[:active] }
        then_action({ access: :full, features: :all })
      end
      
      result = engine.evaluate
      
      expect(result.value[:access]).to eq(:full)
    end
  end
end

