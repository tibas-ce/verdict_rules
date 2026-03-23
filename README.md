<div align="center">

# ⚖️ VerdictRules

### Rule engine para Ruby com prioridades explícitas, resultados rastreáveis e DSL expressiva.

Defina regras de negócio complexas de forma clara, debuggável e pronta para produção.

[![CI](https://github.com/tibas-ce/verdict_rules/workflows/CI/badge.svg)]
[![Gem Version](https://img.shields.io/badge/status-not_published-lightgrey.svg)](https://rubygems.org/gems/verdict_rules)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[Recursos](#-recursos) •
[Instalação](#-instalação) •
[Início Rápido](#-início-rápido) •
[API](#-api) •
[Debugging e Observabilidade](#-debugging-e-observabilidade) •
[Exemplos](#-exemplos)

</div>

---

## 🎯 O que é VerdictRules?

**VerdictRules** é uma gem Ruby leve e sem dependências que permite definir regras de negócio de forma declarativa com nome, prioridades explícitas e resultados explicáveis.

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
| 🏷️ **Regras Nomeadas** | Identifique exatamente qual regra foi aplicada |
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
require "verdict_rules"

context = { age: 25, verified: true }

engine = VerdictRules::Engine.new(context)

engine.rules do
  rule :verified_user, priority: 10 do
    when_condition { |ctx| ctx[:verified] }
    then_action :approve_verified
  end

  rule :adult_user, priority: 1 do
    when_condition { |ctx| ctx[:age] >= 18 }
    then_action :approve_adult
  end
end

result = engine.evaluate

result.value                    # => :approve_verified
result.matched_rule.name       # => :verified_user
```

---

### Problema que resolve

Sem prioridades e rastreabilidade:

- decisões imprevisíveis ❌
- difícil entender por que algo foi aprovado/rejeitado ❌
- debugging lento e custoso ❌

Com VerdictRules:

- decisão previsível ✅
- regra identificável ✅
- lógica centralizada ✅

---
### Exemplo Real: Produção
```ruby
engine.rules do
  rule :vip_customer, priority: 100 do
    when_condition { |ctx| ctx[:vip_customer] }
    then_action({ status: :approved, limit: 50000 })
  end

  rule :income_not_verified, priority: 10 do
    when_condition { |ctx| !ctx[:verified_income] }
    then_action({ status: :manual_review })
  end

  rule :good_credit, priority: 1 do
    when_condition { |ctx| ctx[:credit_score] >= 700 }
    then_action({ status: :approved })
  end
end

result = engine.evaluate

result.to_h
# => {
#      value: { status: :manual_review },
#      matched: true,
#      matched_rule: { name: :income_not_verified, priority: 10, ... }
#    }
```

---

## 🔍 Debugging e Observabilidade
Projetado para sistemas onde decisões precisam ser auditáveis e explicáveis.

```ruby
result = engine.evaluate

result.matched_rule.name
# => :income_not_verified

result.matched_rule.priority
# => 10
```

### 📊 Logging estruturado

```ruby
log = {
  event: "rule_evaluation",
  result: result.value,
  matched: result.matched?,
  rule: result.matched_rule&.to_h
}

puts JSON.pretty_generate(log)
```

### Ideal para cenários como:

- auditoria
- debugging em produção
- sistemas financeiros / críticos

---

## 🔧 API

```ruby
engine.rule(:name, priority: 10) do
  when_condition { |ctx| ... }
  then_action :result
end

engine.rules do
  rule(:a, priority: 10) { ... }
  rule(:b, priority: 5)  { ... }
end

engine.evaluate
```

---

## 💡 Exemplos

Confira o diretório [`examples/`](examples/) para exemplos completos e funcionais:

- **[Uso Básico](examples/basic_usage.rb)** - Regras simples sem DSL
- **[Sistema de Prioridades](examples/priority_and_exceptions.rb)** - Aprovação de crédito com prioridades
- **[DSL Básica](examples/dsl_basic.rb)** - DSL vs API tradicional
- **[DSL no Mundo Real](examples/dsl_real_word.rb)** - Sistema de aprovação de compras
- **[Debugging com regras nomeadas](examples/named_rules_debugging.rb)** - Investigando decisões e logs estruturados

Execute-os:
```bash
ruby examples/basic_usage.rb
```

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

Feito por [Tibério dos Santos Ferreira](https://github.com/tibas-ce)

</div>