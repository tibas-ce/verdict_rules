require_relative "../lib/verdict_rules"

puts "=" * 60
puts "Exemplo 2: Sistema de aprovação de crédito com prioridades"
puts "=" * 60
puts

# Cenário 1: Cliente com score bom, mas sem verificação
puts "CENÁRIO 1: Cliente sem verificação de renda"
puts "-" * 60 

context = {
  credit_score: 750,
  verified_income: false,
  account_age_months: 24,
  vip_customer: false
}

engine = VerdictRules::Engine.new(context)

# Regra 1: Score alto (prioridade baixa - regra geral)
engine.add_rule(
  VerdictRules::Rule.new(
    condition: ->(ctx) { ctx[:credit_score] >= 700 },
    action: { status: :approved, limit: 5000, reason: "Bom score de crédito" },
    priority: 1
  )
)

# Regra 2: Conta antiga (prioridade média)
engine.add_rule(
  VerdictRules::Rule.new(
    condition: ->(ctx) { ctx[:account_age_months] >= 12 },
    action: { status: :approved, limit: 7000, reason: "Cliente com histórico consolidado" },
    priority: 5
  )
)

# Regra 3: Sem verificação de renda (prioridade alta - restrição)
engine.add_rule(
  VerdictRules::Rule.new(
    condition: ->(ctx) { !ctx[:verified_income] },
    action: { status: :manual_review, limit: 2000, reason: "Renda não verificada" },
    priority: 10
  )
)

# Regra 4: Cliente VIP (prioridade máxima - exceção)
# Regras de prioridade mais alta representam exceções ou restrições que devem sobrescrever regras gerais de aprovação.
engine.add_rule(
  VerdictRules::Rule.new(
    condition: ->(ctx) { ctx[:vip_customer] },
    action: { status: :approved, limit: 50000, reason: "Cliente VIP" },
    priority: 100
  )
)

result = engine.evaluate

puts
puts "Contexto:"
puts "  Credit Score: #{context[:credit_score]}"
puts "  Renda Verificada: #{context[:verified_income]}"
puts "  Idade da Conta: #{context[:account_age_months]} meses"
puts "  VIP: #{context[:vip_customer]}"
puts
puts "Resultado:"
puts "  Status: #{result.value[:status]}"
puts "  Limite: R$ #{result.value[:limit]}"
puts "  Razão: #{result.value[:reason]}"
puts "  Prioridade da regra: #{result.matched_rule.priority}"
puts

puts "=" * 60
puts "CENÁRIO 2: Mesmo cliente, mas VIP"
puts "-" * 60

# Cenário 2: Mesmas condições, mas cliente VIP
vip_context = context.merge(vip_customer: true)
vip_engine = VerdictRules::Engine.new(vip_context)

# Adiciona as mesmas regras
# As regras são reutilizáveis e não dependem de estado interno
engine.rules.each { |rule| vip_engine.add_rule(rule) } 

vip_result = vip_engine.evaluate

puts
puts "Contexto:"
puts "  Credit Score: #{vip_context[:credit_score]}"
puts "  Renda Verificada: #{vip_context[:verified_income]}"
puts "  Idade da Conta: #{vip_context[:account_age_months]} meses"
puts "  VIP: #{vip_context[:vip_customer]}"
puts
puts "Resultado:"
puts "  Status: #{vip_result.value[:status]}"
puts "  Limite: R$ #{vip_result.value[:limit]}"
puts "  Razão: #{vip_result.value[:reason]}"
puts "  Prioridade da regra: #{vip_result.matched_rule.priority}"
puts
puts "Regra VIP (priority=100) sobrescreve a restrição!"
puts