require_relative "../lib/verdict_rules"

puts "=" * 60
puts "Exemplo 3: DSL vs API Tradicional"
puts "=" * 60
puts

context = { age: 25, verified: true }

# --- Estilo 1: API Tradicional (verboso) ---
puts "1 - API TRADICIONAL"
puts "-" * 60

engine1 = VerdictRules::Engine.new(context)

engine1.add_rule(
  VerdictRules::Rule.new(
    condition: ->(ctx) { ctx[:age] >= 18 },
    action: :approve,
    priority: 10
  )
)

result1 = engine1.evaluate

puts
puts "Código:"
puts <<~CODE
  engine.add_rule(
    VerdictRules::Rule.new(
      condition: ->(ctx) { ctx[:age] >= 18 },
      action: :approve,
      priority: 10
    )
  )
CODE
puts "Resultado: #{result1.value}"
puts

# --- Estilo 2: DSL (clean) ---
puts "=" * 60
puts "2 - DSL (limpa e expressiva)"
puts "-" * 60

engine2 = VerdictRules::Engine.new(context)

engine2.rule(priority: 10) do
  when_condition { |ctx| ctx[:age] >= 18 }
  then_action :approve
end

result2 = engine2.evaluate

puts
puts "Código:"
puts <<~CODE
  engine.rule(priority: 10) do
    when_condition { |ctx| ctx[:age] >= 18 }
    then_action :approve
  end
CODE
puts "Resultado: #{result2.value}"
puts

# --- Estilo 3: DSL batch (múltiplas regras) ---
# Útil quando várias regras precisam ser definidas juntas de forma declarativa
puts "=" * 60
puts "3 - DSL BATCH (múltiplas regras)"
puts "-" * 60

engine3 = VerdictRules::Engine.new(context)

engine3.rules do
  rule priority: 1 do
    when_condition { |ctx| ctx[:age] >= 18 }
    then_action :approve_adult
  end

  rule priority: 10 do
    when_condition { |ctx| ctx[:verified] }
    then_action :approve_verified
  end
end

result3 = engine3.evaluate

puts
puts "Código:"
puts <<~CODE
  engine.rules do
    rule priority: 1 do
      when_condition { |ctx| ctx[:age] >= 18 }
      then_action :approve_adult
    end
    
    rule priority: 10 do
      when_condition { |ctx| ctx[:verified] }
      then_action :approve_verified
    end
  end
CODE
puts "Resultado: #{result3.value}"
puts "(Regra de maior prioridade venceu)"
puts
puts "Todos os estilos funcionam, DSL é mais legível!"
puts