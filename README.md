<div align="center">

# ⚖️ VerdictRules

### Uma gem Ruby para definir e avaliar regras de negócio com prioridades

[![CI](https://github.com/YOUR_USERNAME/verdict_rules/workflows/CI/badge.svg)](https://github.com/tibas-ce/verdict_rules)
[![Gem Version](https://img.shields.io/badge/gem-v0.1.0-blue.svg)](https://rubygems.org/gems/verdict_rules)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[Recursos](#-recursos) •
[Instalação](#-instalação) •
[Início Rápido](#-início-rápido) •
[Documentação](#-documentação) •
[Exemplos](#-exemplos)

</div>

---

## 🎯 O que é VerdictRules?

**VerdictRules** é uma gem Ruby leve e sem dependências que permite definir regras de negócio de forma declarativa com prioridades explícitas e resultados explicáveis.

Perfeita para:
- 🏦 **Sistemas financeiros**: Aprovação de crédito, detecção de fraude
- 🛒 **E-commerce**: Regras de preço, lógica de descontos
- 🔐 **Autorização**: Controle de acesso, sistemas de permissão
- ✅ **Validação**: Lógica condicional complexa
- 🎮 **Lógica de jogos**: Sistemas de pontuação, conquistas

---

## ✨ Recursos

| Recurso | Descrição |
|---------|-----------|
| 🎯 **Sistema de Prioridades** | Resolve conflitos quando múltiplas regras são verdadeiras |
| 📊 **Resultados Explicáveis** | Saiba qual regra foi aplicada e por quê |
| ✨ **DSL Expressiva** | Sintaxe limpa e legível |
| 🔒 **Contexto Imutável** | Comportamento thread-safe e previsível |
| 🧪 **100% de Cobertura** | Testado e confiável |
| 📦 **Zero Dependências** | Leve e rápida |
| 🚀 **Design pronto para produção** | Arquitetura preparada para uso real |

---

## 📦 Instalação

Adicione esta linha ao Gemfile da sua aplicação:
```ruby
gem 'verdict_rules'
```

E então execute:
```bash
bundle install
```

Ou instale você mesmo:
```bash
gem install verdict_rules
```

---

## 🚀 Início Rápido

### Exemplo Básico
```ruby
require 'verdict_rules'

# Defina seu contexto (imutável)
context = { age: 25, verified: true, country: "BR" }

# Crie uma engine
engine = VerdictRules::Engine.new(context)

# Defina regras com prioridades
engine.rules do
  rule priority: 10 do
    when_condition { |ctx| ctx[:verified] }
    then_action :approve_verified
  end
  
  rule priority: 1 do
    when_condition { |ctx| ctx[:age] >= 18 }
    then_action :approve_adult
  end
end

# Avalie
result = engine.evaluate

result.value          # => :approve_verified
result.matched?       # => true
result.matched_rule   # => #<VerdictRules::Rule priority=10>
```

### Exemplo do Mundo Real: Aprovação de Crédito
```ruby
# Cliente solicitando crédito
context = {
  credit_score: 750,
  verified_income: false,
  account_age_months: 24,
  vip_customer: false
}

engine = VerdictRules::Engine.new(context)

engine.rules do
  # Clientes VIP ignoram todas as verificações (prioridade máxima)
  rule priority: 100 do
    when_condition { |ctx| ctx[:vip_customer] }
    then_action({ status: :approved, limit: 50000, reason: "Cliente VIP" })
  end
  
  # Verificação de renda obrigatória (restrição de alta prioridade)
  rule priority: 10 do
    when_condition { |ctx| !ctx[:verified_income] }
    then_action({ status: :manual_review, limit: 2000, reason: "Renda não verificada" })
  end
  
  # Bom score de crédito (regra geral)
  rule priority: 1 do
    when_condition { |ctx| ctx[:credit_score] >= 700 }
    then_action({ status: :approved, limit: 5000, reason: "Bom score de crédito" })
  end
end

result = engine.evaluate
# => { status: :manual_review, limit: 2000, reason: "Renda não verificada" }
# Regra de maior prioridade (10) vence a regra geral (1)
```

---

## 🎨 Por que Prioridades Importam
```ruby
context = { age: 25, verified: true }

engine = VerdictRules::Engine.new(context)

# ❌ Sem prioridades: ordem de inserção decide
engine.add_rule(
  VerdictRules::Rule.new(
    condition: ->(ctx) { ctx[:age] >= 18 },
    action: :approve_by_age
  )
)
# Primeira regra vence ⬆️

# ✅ Com prioridades: controle explícito
engine.rules do
  rule priority: 1 do
    when_condition { |ctx| ctx[:age] >= 18 }
    then_action :approve_by_age
  end
  
  rule priority: 10 do
    when_condition { |ctx| ctx[:verified] }
    then_action :approve_by_verification
  end
end
# Maior prioridade vence ⬆️
```

---

## 📚 Documentação

### Conceitos Principais

#### 1. **Contexto (Context)**
Hash imutável contendo todos os dados necessários para avaliação.
```ruby
context = { user_id: 123, amount: 1000, country: "BR" }
engine = VerdictRules::Engine.new(context)

# Contexto é congelado - não pode ser modificado
engine.context[:amount] = 2000  # ❌ Lança FrozenError
```

#### 2. **Regras (Rules)**
Uma regra consiste em:
- **Condição**: Lambda que retorna true/false
- **Ação**: Valor a retornar se a condição for verdadeira
- **Prioridade**: Número (maior = mais importante)
```ruby
VerdictRules::Rule.new(
  condition: ->(ctx) { ctx[:age] >= 18 },
  action: :approve,
  priority: 10
)
```

#### 3. **Motor (Engine)**
Gerencia regras e as avalia contra o contexto.
```ruby
engine = VerdictRules::Engine.new(context)
engine.add_rule(rule)
result = engine.evaluate
```

#### 4. **Resultado (Result)**
Objeto rico explicando o que aconteceu:
```ruby
result.value          # O valor da ação
result.matched?       # Alguma regra bateu?
result.matched_rule   # Qual regra bateu
result.to_h           # Hash para logging
result.inspect        # Info de debug legível
```

---

## 🔧 Referência da API

### Engine
```ruby
# Criar engine
engine = VerdictRules::Engine.new(context)

# Adicionar regra (API tradicional)
engine.add_rule(rule)

# Adicionar regra (DSL)
engine.rule(priority: 10) do
  when_condition { |ctx| ctx[:age] >= 18 }
  then_action :approve
end

# Adicionar múltiplas regras (DSL batch)
engine.rules do
  rule(priority: 10) { ... }
  rule(priority: 5) { ... }
end

# Avaliar
result = engine.evaluate

# Acessar regras
engine.rules          # Array de regras (ordenadas por prioridade)
engine.context        # O hash de contexto congelado
```

### Rule
```ruby
rule = VerdictRules::Rule.new(
  condition: ->(ctx) { ctx[:age] >= 18 },
  action: :approve,
  priority: 10  # padrão: 0
)

rule.evaluate(context)  # Retorna action ou nil
rule.matches?(context)  # Retorna true/false
rule.priority           # Retorna número da prioridade
```

### Result
```ruby
result = engine.evaluate

result.value          # A ação (ou nil)
result.matched?       # Boolean
result.matched_rule   # Objeto Rule (ou nil)
result.to_h           # { value: ..., matched: ..., matched_rule: ... }
result.inspect        # "#<VerdictRules::Result value=:approve matched=true>"
```

---

## 💡 Exemplos

Confira o diretório [`examples/`](examples/) para exemplos completos e funcionais:

- **[Uso Básico](examples/basic_usage.rb)** - Regras simples sem DSL
- **[Sistema de Prioridades](examples/priority_and_exceptions.rb)** - Aprovação de crédito com prioridades
- **[DSL Básica](examples/dsl_basic.rb)** - DSL vs API tradicional
- **[DSL no Mundo Real](examples/dsl_real_word.rb)** - Sistema de aprovação de compras

Execute-os:
```bash
ruby examples/basic_usage.rb
```

---

## 🧪 Desenvolvimento
```bash
# Clone o repositório
git clone https://github.com/YOUR_USERNAME/verdict_rules.git
cd verdict_rules

# Instale as dependências
bundle install

# Execute os testes
bundle exec rspec

# Execute os testes com coverage
bundle exec rspec
open coverage/index.html

# Execute os exemplos
ruby examples/run_all.rb
```

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para enviar um Pull Request.

1. Faça um fork do repositório
2. Crie sua branch de feature (`git checkout -b feature/recurso-incrivel`)
3. Commit suas mudanças (`git commit -m 'Adiciona recurso incrível'`)
4. Push para a branch (`git push origin feature/recurso-incrivel`)
5. Abra um Pull Request

---

## 📊 Princípios de Design

VerdictRules segue estes princípios:

- ✅ **Explícito sobre Implícito** - Sem mágica, comportamento claro
- ✅ **Simples sobre Complexo** - Fácil de entender e debugar
- ✅ **Testável** - Cada componente tem testes unitários
- ✅ **Imutável** - Contexto não pode ser modificado
- ✅ **Explicável** - Resultados dizem por que aconteceram
- ✅ **Componível** - Misture DSL e API tradicional livremente

---

## 🗺️ Roadmap

- [x] Motor de regras principal
- [x] Sistema de prioridades
- [x] Resultados explicáveis
- [x] DSL expressiva
- [x] 100% de cobertura de testes
- [ ] Regras nomeadas
- [ ] Histórico de avaliação
- [ ] Descrições de regras
- [ ] Benchmarks de performance

---

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

---

## 🙏 Construído usando

- Ruby
- RSpec
- SimpleCov

---

<div align="center">

**[⬆ voltar ao topo](#️-verdictrules)**

Feito por Tibério dos Santos Ferreira(https://github.com/tibas-ce)

</div>