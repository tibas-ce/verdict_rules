require_relative "../lib/verdict_rules"
require "time"
require "json"

puts "=" * 60
puts "Exemplo 5: Debugging com Named Rules"
puts "=" * 60
puts

# Simular um bug: regra não está batendo como esperado
context = {
  user_type: :premium,
  purchase_amount: 1500,
  account_age_days: 10
}

engine = VerdictRules::Engine.new(context)

engine.rules do
  rule :vip_discount, priority: 100 do
    when_condition { |ctx| ctx[:user_type] == :vip }
    then_action({ discount: 0.30, reason: "VIP customer" })
  end
  
  rule :premium_high_value, priority: 50 do
    when_condition { |ctx| 
      ctx[:user_type] == :premium && 
      ctx[:purchase_amount] > 1000 
    }
    then_action({ discount: 0.20, reason: "Premium high value purchase" })
  end
  
  rule :new_account_restriction, priority: 40 do
    when_condition { |ctx| ctx[:account_age_days] < 30 }
    then_action({ discount: 0.05, reason: "New account - limited discount" })
  end
  
  rule :premium_standard, priority: 30 do
    when_condition { |ctx| ctx[:user_type] == :premium }
    then_action({ discount: 0.15, reason: "Premium customer" })
  end
  
  rule :standard_discount, priority: 1 do
    when_condition { |ctx| true }
    then_action({ discount: 0.10, reason: "Standard discount" })
  end
end

result = engine.evaluate

puts
puts "Cenário:"
puts "Esperamos que compras altas de usuários premium recebam o melhor desconto."
puts "Porém, regras com maior prioridade podem interferir."
puts
puts "Contexto:"
puts "  Tipo de Usuário: #{context[:user_type]}"
puts "  Valor da Compra: R$ #{context[:purchase_amount]}"
puts "  Idade da Conta: #{context[:account_age_days]} dias"

puts
puts "Resultado:"
puts "  Desconto: #{(result.value[:discount] * 100).round(0)}%"
puts "  Razão: #{result.value[:reason]}"

puts
puts "Debug Info:"
puts "  Regra Aplicada: #{result.matched_rule.name.inspect}"
puts "  Prioridade: #{result.matched_rule.priority}"

puts
puts "=" * 60
puts "ANÁLISE DO DEBUG:"
puts "=" * 60
puts
puts "Esperado: :premium_high_value (20% desconto)"
puts "Obtido: #{result.matched_rule.name} (#{(result.value[:discount] * 100).round(0)}% desconto)"
if result.matched_rule.name != :premium_high_value
  puts "Regra inesperada aplicada! Verifique prioridades."
end
puts
puts "O nome da regra revela imediatamente qual regra bateu!"
puts "Sem nomes, você teria que inspecionar cada regra manualmente."
puts

puts "=" * 60
puts "TODAS AS REGRAS DISPONÍVEIS:"
puts "=" * 60
puts
engine.rules.each do |rule|
  puts "  #{rule.name.inspect} (priority: #{rule.priority})"
end
puts
puts "=" * 60
puts "LOG ESTRUTURADO (PRODUÇÃO)"
puts "=" * 60
puts

log_entry = {
  timestamp: Time.now.iso8601,
  event: "rule_evaluation",
  context: context,
  result: result.value,
  matched: result.matched?,
  rule: result.matched_rule&.to_h
}

puts JSON.pretty_generate(log_entry)
puts
puts "Nomes transformam regras em entidades rastreáveis."
puts "Em sistemas reais, isso evita horas de debugging."
puts