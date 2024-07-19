FactoryBot.define do
  factory :transaction do
    sequence(:transaction_id) { |n| n + 100 }
    sequence(:merchant_id) { |n| n + 500 }
    sequence(:user_id) { |n| n + 800 }
    card_number { "1234********4321" }
    transaction_date { DateTime.now }
    transaction_amount { 42.42 }
    sequence(:device_id) { |n| n + 900 }
    sequence(:has_cbk, [true, false].cycle)
  end
end
