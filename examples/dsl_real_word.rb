require_relative "../lib/verdict_rules"

puts "=" * 60
puts "Exemplo 4: Sistema de Aprovação de Compras (DSL)"
puts "=" * 60
puts

# Contexto: Cliente fazendo uma compra
purchase = {
    amount: 5000,
    customer_tier: :gold,
    payment_method: :credit_card,
    account_age_days: 180,
    previous_chargebacks: 0,
    shipping_country: "BR"
}

engine = VerdictRules::Engine.new(purchase)

# Define regras de aprovação usando DSL
# As regras são avaliadas por prioridade (maior primeiro). A primeira regra que bater define o resultado final
engine.rules do
  # Regra 1: Bloqueio de segurança (exceção crítica)
  rule priority: 100 do
    when_condition { |ctx| ctx[:previous_chargebacks] > 2 }
    then_action({
      status: :blocked,
      reason: "Too many chargebacks"
    })
  end

  # Regra 2: Cliente gold tem aprovação atomática
  rule priority: 50 do
    when_condition { |ctx| 
      ctx[:customer_tier] == :gold &&
      ctx[:amount] <= 10000
    }
    then_action({
      status: :approved,
      reason: "Gold customer - auto approved",
      review_required: false
    })
  end

  # Regra 3: Conta nova requer revisão manual
  rule priority: 40 do
    when_condition { |ctx| ctx[:account_age_days] < 30 }
    then_action({
      status: :pending,
      reason: "New account - manual review",
      review_required: true
    })
  end

  # Regra 4: Compras internacionais acima de certo valor
  rule priority: 30 do
    when_condition { |ctx| 
      ctx[:shipping_country] != "BR" && 
      ctx[:amount] > 3000 
    }
    then_action({
      status: :pending,
      reason: "High value international order",
      review_required: true
    })
  end
  
  # Regra 5: Aprovação padrão
  # Regra final de fallback: garante que toda avaliação produza uma decisão explícita
  rule priority: 0 do
    when_condition { |_ctx| true }
    then_action({
      status: :pending,
      reason: "Default manual review",
      review_required: true
    })
  end
end


result = engine.evaluate

puts
puts "Contexto da Compra:"
puts "  Valor: R$ #{purchase[:amount]}"
puts "  Cliente: #{purchase[:customer_tier]}"
puts "  Método: #{purchase[:payment_method]}"
puts "  Idade da conta: #{purchase[:account_age_days]} dias"
puts "  Chargebacks anteriores: #{purchase[:previous_chargebacks]}"
puts "  País de envio: #{purchase[:shipping_country]}"

puts
puts "Resultado da Avaliação:"
puts "  Status: #{result.value[:status]}"
puts "  Razão: #{result.value[:reason]}"
puts "  Revisão necessária: #{result.value[:review_required]}"
puts "  Regra aplicada: priority=#{result.matched_rule.priority}"

puts
puts "A DSL torna as regras de negócio claras e manuteníveis!"
puts