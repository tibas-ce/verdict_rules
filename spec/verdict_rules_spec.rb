# frozen_string_literal: true

RSpec.describe VerdictRules do

  it "pode ser carregada sem erros" do
    expect { VerdictRules }.not_to raise_error
  end

  it "define módulo principal VerdictRules" do
    expect(defined?(VerdictRules)).to eq("constant")
    expect(VerdictRules).to be_a (Module)
  end

  describe "VERSION" do
    it "tem número de versão" do
      expect(VerdictRules::VERSION).not_to be nil
    end

    it "está definida como uma constante" do
      expect(defined?(VerdictRules::VERSION)).to eq("constant")
    end
    
    it "é uma string" do
      expect(VerdictRules::VERSION).to be_a(String)
      expect(VerdictRules::VERSION).not_to be_empty
    end

    it "segue o formato de versão semântica" do
      expect(VerdictRules::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
    end
  end

  describe "ENGINE" do
    it "define a classe VerdictRules::Engine" do
      expect(defined?(VerdictRules::Engine)).to eq("constant")
      expect(VerdictRules::Engine).to be_a(Class)
    end
  end
end
