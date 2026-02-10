require_relative "../lib/verdict_rules"

puts "=" * 60
puts "Exemplo 1: Uso Básico da Gem"
puts "=" * 60
puts

# Criar contexto
context = {
  age: 25,
  country: "BR",
  verified: true
}

# Criar engine
engine = VerdictRules::Engine.new(context)

# Adicionar regras
minor_rule = VerdictRules::Rule.new(
  condition: ->(ctx) { ctx[:age] < 18 },
  action: :reject_minor
)

verified_adult_rule = VerdictRules::Rule.new(
  condition: ->(ctx) { ctx[:age] >= 18 && ctx[:verified] },
  action: :approve_verified_adult
)

adult_rule = VerdictRules::Rule.new(
  condition: ->(ctx) { ctx[:age] >= 18 },
  action: :approve_adult
)

engine
  .add_rule(minor_rule)
  .add_rule(verified_adult_rule)
  .add_rule(adult_rule)

# Avaliar
result = engine.evaluate

puts "Contexto:"
puts "  Idade: #{context[:age]}"
puts "  País: #{context[:country]}"
puts "  Verificado: #{context[:verified]}"
puts
puts "Resultado da Avaliação:"
puts "  Valor: #{result.value}"
puts "  Regra bateu? #{result.matched?}"
puts "  Regra aplicada: #{result.matched_rule.inspect}"
puts
puts "Inspeção:"
puts "  #{result.inspect}"
puts
puts "Hash (para logging):"
puts "  #{result.to_h}"
puts