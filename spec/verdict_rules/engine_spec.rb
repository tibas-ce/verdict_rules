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
end
